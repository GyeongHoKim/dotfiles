# dotfiles 설치 가이드 (한국어)

이 저장소는 macOS, Linux, Windows를 모두 지원하는 크로스 플랫폼 dotfiles입니다.

## 🚀 빠른 설치

### Windows 사용자

```powershell
# 1. 저장소 클론
git clone https://github.com/gyeonghokim/dotfiles.git
cd dotfiles

# 2. PowerShell 실행 정책 설정
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. 설치 스크립트 실행
./install.ps1
# 또는
./install.bat
```

### macOS/Linux 사용자

```bash
# 1. 저장소 클론
git clone https://github.com/gyeonghokim/dotfiles.git
cd dotfiles

# 2. 설치 스크립트 실행
./install
```

## 📋 설치 과정

설치 프로그램은 다음과 같은 작업을 수행합니다:

1. **운영체제 선택**: Windows, macOS, Linux 중 선택
2. **패키지 관리자 설치**: 
   - Windows: Scoop/Chocolatey/Winget
   - macOS: Homebrew
   - Linux: apt/yum/pacman
3. **개발 도구 설치**:
   - Neovim (LazyVim 설정 포함)
   - Git, Ripgrep, fd, fzf, LazyGit
   - Nerd Font (아이콘 지원)
4. **셸 설정**:
   - Unix: Zsh + Oh My Zsh
   - Windows: PowerShell + Oh My Posh

## 🪟 Windows 추가 설정

### Windows Terminal 설치 (권장)
```powershell
winget install Microsoft.WindowsTerminal
```

### 폰트 설정
1. Windows Terminal 설정 열기 (Ctrl+,)
2. 프로필 → 기본값 → 모양
3. 글꼴을 "Hack Nerd Font"로 변경

### PowerShell 프로필 수정
```powershell
# 프로필 편집
notepad $PROFILE

# 테마 변경 (선택사항)
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/다른테마.omp.json"
```

## 🔧 문제 해결

### Windows에서 스크립트 실행 오류
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 심볼릭 링크 생성 실패
- 관리자 권한으로 PowerShell 실행
- 또는 Windows 설정에서 개발자 모드 활성화

### 폰트가 제대로 표시되지 않음
[Nerd Fonts](https://www.nerdfonts.com/)에서 폰트를 다운로드하여 설치

## 📚 추가 정보

- [상세 Windows 설정 가이드](WINDOWS.md)
- [영문 README](README.md)
- [문제 신고](https://github.com/gyeonghokim/dotfiles/issues)
