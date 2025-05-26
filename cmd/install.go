package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

// Platform-specific configuration
type Platform struct {
	Name             string
	PackageManager   string
	Shell            string
	ConfigPath       string
	NvimConfigPath   string
	ShellConfigFile  string
}

// Installation steps
type Step struct {
	Name        string
	Description string
	Command     func() error
}

// Model for the TUI
type model struct {
	platform     Platform
	steps        []Step
	currentStep  int
	done         bool
	err          error
	spinner      spinner.Model
	progress     string
	selectedOS   string
	list         list.Model
}

// Messages
type (
	stepCompleteMsg struct{ err error }
	osSelectedMsg   struct{ os string }
)

func initialModel() model {
	// OS selection list
	items := []list.Item{
		item{title: "Windows", desc: "Windows 10/11 with PowerShell"},
		item{title: "macOS", desc: "macOS with Homebrew and Zsh"},
		item{title: "Linux", desc: "Linux with apt/yum and Zsh"},
	}

	l := list.New(items, list.NewDefaultDelegate(), 30, 10)
	l.Title = "Select Your Operating System"
	l.SetShowStatusBar(false)
	l.SetFilteringEnabled(false)

	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.Color("205"))

	return model{
		spinner: s,
		list:    l,
	}
}

type item struct {
	title, desc string
}

func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title }

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case tea.KeyMsg:
		if m.selectedOS == "" {
			switch msg.String() {
			case "ctrl+c", "q":
				return m, tea.Quit
			case "enter":
				i, ok := m.list.SelectedItem().(item)
				if ok {
					m.selectedOS = i.title
					m.platform = getPlatform(i.title)
					m.steps = getSteps(m.platform)
					return m, m.runNextStep()
				}
			}
		} else {
			switch msg.String() {
			case "ctrl+c", "q":
				return m, tea.Quit
			}
		}

	case stepCompleteMsg:
		if msg.err != nil {
			m.err = msg.err
			m.done = true
			return m, tea.Quit
		}
		m.currentStep++
		if m.currentStep >= len(m.steps) {
			m.done = true
			return m, tea.Quit
		}
		return m, m.runNextStep()

	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		return m, cmd
	}

	// Update list if OS not selected
	if m.selectedOS == "" {
		var cmd tea.Cmd
		m.list, cmd = m.list.Update(msg)
		return m, cmd
	}

	return m, nil
}

func (m model) View() string {
	if m.selectedOS == "" {
		return m.list.View()
	}

	if m.err != nil {
		return fmt.Sprintf("\n❌ Error: %v\n", m.err)
	}

	if m.done {
		return fmt.Sprintf("\n✅ Installation complete!\n\n" +
			"Next steps:\n" +
			"1. Restart your terminal\n" +
			"2. Run 'nvim' to start Neovim\n" +
			"3. LazyVim will install plugins on first run\n")
	}

	s := fmt.Sprintf("\n%s Installing dotfiles for %s...\n\n", m.spinner.View(), m.platform.Name)
	
	for i, step := range m.steps {
		if i < m.currentStep {
			s += fmt.Sprintf("✅ %s\n", step.Name)
		} else if i == m.currentStep {
			s += fmt.Sprintf("%s %s\n", m.spinner.View(), step.Name)
		} else {
			s += fmt.Sprintf("⏳ %s\n", step.Name)
		}
	}
	
	if m.progress != "" {
		s += fmt.Sprintf("\n%s\n", m.progress)
	}

	return s
}

func (m model) runNextStep() tea.Cmd {
	return tea.Batch(
		m.spinner.Tick,
		func() tea.Msg {
			step := m.steps[m.currentStep]
			err := step.Command()
			return stepCompleteMsg{err}
		},
	)
}

func getPlatform(osName string) Platform {
	homeDir, _ := os.UserHomeDir()
	
	switch osName {
	case "Windows":
		return Platform{
			Name:            "Windows",
			PackageManager:  detectWindowsPackageManager(),
			Shell:           "powershell",
			ConfigPath:      filepath.Join(homeDir, "AppData", "Local"),
			NvimConfigPath:  filepath.Join(homeDir, "AppData", "Local", "nvim"),
			ShellConfigFile: filepath.Join(homeDir, "Documents", "PowerShell", "Microsoft.PowerShell_profile.ps1"),
		}
	case "macOS":
		return Platform{
			Name:            "macOS",
			PackageManager:  "brew",
			Shell:           "zsh",
			ConfigPath:      filepath.Join(homeDir, ".config"),
			NvimConfigPath:  filepath.Join(homeDir, ".config", "nvim"),
			ShellConfigFile: filepath.Join(homeDir, ".zshrc"),
		}
	default: // Linux
		return Platform{
			Name:            "Linux",
			PackageManager:  detectLinuxPackageManager(),
			Shell:           "zsh",
			ConfigPath:      filepath.Join(homeDir, ".config"),
			NvimConfigPath:  filepath.Join(homeDir, ".config", "nvim"),
			ShellConfigFile: filepath.Join(homeDir, ".zshrc"),
		}
	}
}

func detectWindowsPackageManager() string {
	// Check for Scoop
	if _, err := exec.LookPath("scoop"); err == nil {
		return "scoop"
	}
	// Check for Chocolatey
	if _, err := exec.LookPath("choco"); err == nil {
		return "choco"
	}
	// Default to winget
	return "winget"
}

func detectLinuxPackageManager() string {
	if _, err := exec.LookPath("apt"); err == nil {
		return "apt"
	}
	if _, err := exec.LookPath("yum"); err == nil {
		return "yum"
	}
	if _, err := exec.LookPath("pacman"); err == nil {
		return "pacman"
	}
	return "apt" // default
}

func getSteps(p Platform) []Step {
	switch p.Name {
	case "Windows":
		return getWindowsSteps(p)
	case "macOS":
		return getMacOSSteps(p)
	default:
		return getLinuxSteps(p)
	}
}

func getWindowsSteps(p Platform) []Step {
	return []Step{
		{
			Name:        "Install Package Manager",
			Description: "Ensuring package manager is installed",
			Command: func() error {
				if p.PackageManager == "scoop" || p.PackageManager == "choco" {
					return nil // Already installed
				}
				// Install Scoop if no package manager found
				cmd := exec.Command("powershell", "-Command",
					"Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser; "+
						"Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression")
				return cmd.Run()
			},
		},
		{
			Name:        "Install Neovim",
			Description: "Installing Neovim",
			Command: func() error {
				var cmd *exec.Cmd
				switch p.PackageManager {
				case "scoop":
					cmd = exec.Command("scoop", "install", "neovim")
				case "choco":
					cmd = exec.Command("choco", "install", "neovim", "-y")
				default:
					cmd = exec.Command("winget", "install", "Neovim.Neovim")
				}
				return cmd.Run()
			},
		},
		{
			Name:        "Install Git",
			Description: "Installing Git",
			Command: func() error {
				var cmd *exec.Cmd
				switch p.PackageManager {
				case "scoop":
					cmd = exec.Command("scoop", "install", "git")
				case "choco":
					cmd = exec.Command("choco", "install", "git", "-y")
				default:
					cmd = exec.Command("winget", "install", "Git.Git")
				}
				return cmd.Run()
			},
		},
		{
			Name:        "Install Development Tools",
			Description: "Installing ripgrep, fd, fzf, and other tools",
			Command: func() error {
				tools := []string{"ripgrep", "fd", "fzf", "lazygit"}
				for _, tool := range tools {
					var cmd *exec.Cmd
					switch p.PackageManager {
					case "scoop":
						cmd = exec.Command("scoop", "install", tool)
					case "choco":
						cmd = exec.Command("choco", "install", tool, "-y")
					default:
						// winget names might be different
						wingetNames := map[string]string{
							"ripgrep": "BurntSushi.ripgrep",
							"fd":      "sharkdp.fd",
							"fzf":     "junegunn.fzf",
							"lazygit": "JesseDuffield.lazygit",
						}
						cmd = exec.Command("winget", "install", wingetNames[tool])
					}
					if err := cmd.Run(); err != nil {
						fmt.Printf("Warning: Failed to install %s: %v\n", tool, err)
					}
				}
				return nil
			},
		},
		{
			Name:        "Install Nerd Font",
			Description: "Installing Hack Nerd Font",
			Command: func() error {
				if p.PackageManager == "scoop" {
					// Add nerd-fonts bucket
					exec.Command("scoop", "bucket", "add", "nerd-fonts").Run()
					return exec.Command("scoop", "install", "Hack-NF").Run()
				}
				// For other package managers, provide instructions
				fmt.Println("Please install a Nerd Font manually from: https://www.nerdfonts.com/")
				return nil
			},
		},
		{
			Name:        "Setup Neovim Config",
			Description: "Linking Neovim configuration",
			Command: func() error {
				// Create config directory if it doesn't exist
				configDir := filepath.Dir(p.NvimConfigPath)
				if err := os.MkdirAll(configDir, 0755); err != nil {
					return err
				}

				// Remove existing config if present
				os.RemoveAll(p.NvimConfigPath)

				// Create symbolic link
				sourceConfig := filepath.Join(".", "nvim", ".config", "nvim")
				absSource, _ := filepath.Abs(sourceConfig)
				
				// On Windows, use mklink /D for directory symlink
				cmd := exec.Command("cmd", "/c", "mklink", "/D", p.NvimConfigPath, absSource)
				return cmd.Run()
			},
		},
		{
			Name:        "Setup PowerShell Profile",
			Description: "Creating PowerShell profile with aliases",
			Command: func() error {
				profileDir := filepath.Dir(p.ShellConfigFile)
				if err := os.MkdirAll(profileDir, 0755); err != nil {
					return err
				}

				profile := `# PowerShell Profile
# Generated by dotfiles installer

# Aliases
Set-Alias -Name vi -Value nvim
Set-Alias -Name vim -Value nvim
Set-Alias -Name lg -Value lazygit

# Functions
function zshconf { code $PROFILE }
function zshsrc { . $PROFILE }

# Environment Variables
$env:EDITOR = "nvim"

# Oh-My-Posh (PowerShell equivalent of Oh-My-Zsh)
# Install: winget install JanDeDobbeleer.OhMyPosh -s winget
# Then uncomment the following line and choose a theme:
# oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/agnoster.omp.json" | Invoke-Expression

# Posh-Git for Git integration
# Install: Install-Module posh-git -Scope CurrentUser -Force
# Import-Module posh-git

# PSReadLine for better command line editing
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Emacs

Write-Host "Welcome to PowerShell $($PSVersionTable.PSVersion)" -ForegroundColor Green
`
				return os.WriteFile(p.ShellConfigFile, []byte(profile), 0644)
			},
		},
		{
			Name:        "Install Terminal Enhancements",
			Description: "Installing Oh-My-Posh and terminal modules",
			Command: func() error {
				// Install Oh-My-Posh
				cmd := exec.Command("winget", "install", "JanDeDobbeleer.OhMyPosh", "-s", "winget")
				cmd.Run()

				// Install PowerShell modules
				psCmd := `
Install-Module -Name posh-git -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
`
				return exec.Command("powershell", "-Command", psCmd).Run()
			},
		},
	}
}

func getMacOSSteps(p Platform) []Step {
	return []Step{
		{
			Name:        "Install Homebrew",
			Description: "Ensuring Homebrew is installed",
			Command: func() error {
				if _, err := exec.LookPath("brew"); err != nil {
					cmd := exec.Command("/bin/bash", "-c",
						"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)")
					return cmd.Run()
				}
				return nil
			},
		},
		{
			Name:        "Install LazyVim Dependencies",
			Description: "Installing Neovim and development tools",
			Command: func() error {
				return exec.Command("bash", "./setup-lazyvim.sh").Run()
			},
		},
		{
			Name:        "Setup Oh My Zsh",
			Description: "Installing Oh My Zsh and plugins",
			Command: func() error {
				return exec.Command("bash", "./setup-zsh.sh").Run()
			},
		},
		{
			Name:        "Install NVM",
			Description: "Installing Node Version Manager",
			Command: func() error {
				return exec.Command("bash", "./setup-nvm.sh").Run()
			},
		},
		{
			Name:        "Link Configuration Files",
			Description: "Creating symbolic links for dotfiles",
			Command: func() error {
				// Run dotbot
				return exec.Command("./install").Run()
			},
		},
	}
}

func getLinuxSteps(p Platform) []Step {
	return []Step{
		{
			Name:        "Update Package Manager",
			Description: "Updating package lists",
			Command: func() error {
				switch p.PackageManager {
				case "apt":
					return exec.Command("sudo", "apt", "update").Run()
				case "yum":
					return exec.Command("sudo", "yum", "update", "-y").Run()
				case "pacman":
					return exec.Command("sudo", "pacman", "-Sy").Run()
				}
				return nil
			},
		},
		{
			Name:        "Install Neovim",
			Description: "Installing Neovim",
			Command: func() error {
				switch p.PackageManager {
				case "apt":
					// Add Neovim PPA for latest version
					exec.Command("sudo", "add-apt-repository", "ppa:neovim-ppa/unstable", "-y").Run()
					exec.Command("sudo", "apt", "update").Run()
					return exec.Command("sudo", "apt", "install", "neovim", "-y").Run()
				case "yum":
					return exec.Command("sudo", "yum", "install", "neovim", "-y").Run()
				case "pacman":
					return exec.Command("sudo", "pacman", "-S", "neovim", "--noconfirm").Run()
				}
				return nil
			},
		},
		{
			Name:        "Install Development Tools",
			Description: "Installing git, ripgrep, fd, fzf, and other tools",
			Command: func() error {
				var packages []string
				switch p.PackageManager {
				case "apt":
					packages = []string{"git", "ripgrep", "fd-find", "fzf", "curl", "wget", "build-essential"}
				case "yum":
					packages = []string{"git", "ripgrep", "fd-find", "fzf", "curl", "wget", "gcc", "make"}
				case "pacman":
					packages = []string{"git", "ripgrep", "fd", "fzf", "curl", "wget", "base-devel"}
				}
				
				args := append([]string{p.PackageManager, "install"}, packages...)
				if p.PackageManager == "apt" || p.PackageManager == "yum" {
					args = append(args, "-y")
				} else if p.PackageManager == "pacman" {
					args = append(args, "--noconfirm")
				}
				
				return exec.Command("sudo", args...).Run()
			},
		},
		{
			Name:        "Install Zsh",
			Description: "Installing Zsh shell",
			Command: func() error {
				var cmd *exec.Cmd
				switch p.PackageManager {
				case "apt":
					cmd = exec.Command("sudo", "apt", "install", "zsh", "-y")
				case "yum":
					cmd = exec.Command("sudo", "yum", "install", "zsh", "-y")
				case "pacman":
					cmd = exec.Command("sudo", "pacman", "-S", "zsh", "--noconfirm")
				}
				return cmd.Run()
			},
		},
		{
			Name:        "Setup Oh My Zsh",
			Description: "Installing Oh My Zsh and plugins",
			Command: func() error {
				// Make script executable
				exec.Command("chmod", "+x", "./setup-zsh.sh").Run()
				return exec.Command("bash", "./setup-zsh.sh").Run()
			},
		},
		{
			Name:        "Install NVM",
			Description: "Installing Node Version Manager",
			Command: func() error {
				// Make script executable
				exec.Command("chmod", "+x", "./setup-nvm.sh").Run()
				return exec.Command("bash", "./setup-nvm.sh").Run()
			},
		},
		{
			Name:        "Install LazyGit",
			Description: "Installing LazyGit",
			Command: func() error {
				// Try to install via package manager first
				switch p.PackageManager {
				case "apt":
					// Add LazyGit PPA
					exec.Command("sudo", "add-apt-repository", "ppa:lazygit-team/release", "-y").Run()
					exec.Command("sudo", "apt", "update").Run()
					return exec.Command("sudo", "apt", "install", "lazygit", "-y").Run()
				case "pacman":
					return exec.Command("sudo", "pacman", "-S", "lazygit", "--noconfirm").Run()
				default:
					// Install from binary
					cmd := `
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
`
					return exec.Command("bash", "-c", cmd).Run()
				}
			},
		},
		{
			Name:        "Install Nerd Font",
			Description: "Installing Hack Nerd Font",
			Command: func() error {
				cmd := `
mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts
curl -fLo "Hack Regular Nerd Font Complete.ttf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf
fc-cache -fv
`
				return exec.Command("bash", "-c", cmd).Run()
			},
		},
		{
			Name:        "Link Configuration Files",
			Description: "Creating symbolic links for dotfiles",
			Command: func() error {
				// Make install script executable
				exec.Command("chmod", "+x", "./install").Run()
				// Run dotbot
				return exec.Command("./install").Run()
			},
		},
	}
}

func main() {
	p := tea.NewProgram(initialModel())
	if _, err := p.Run(); err != nil {
		fmt.Printf("Error: %v\n", err)
		os.Exit(1)
	}
}
