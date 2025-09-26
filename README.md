# macOS Dotfiles

한국어 개발 환경에 최적화된 macOS용 개발 환경 설정

## 포함된 도구

| 카테고리 | 도구 |
|----------|------|
| Editor | Neovim + LazyVim |
| Terminal | WezTerm (Nightly) |
| Shell | Fish + Starship |
| Multiplexer | tmux |
| AI | OpenCode + MCP servers |
| Languages | Python (Miniconda), Node.js, Go, Rust |
| Kubernetes | kubectl, kubectx, k9s, aws-vault |

## 빠른 시작

```bash
git clone https://github.com/ZergRocks/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

Fish를 기본 셸로 설정:
```bash
chsh -s $(which fish)
```

## 디렉토리 구조

```
dotfiles/
├── nvim/.config/nvim/       # Neovim/LazyVim 설정
├── wezterm/.config/wezterm/ # WezTerm 터미널 설정
├── fish/.config/fish/       # Fish shell 설정
├── tmux/.config/tmux/       # tmux 설정
├── opencode/.config/opencode/ # OpenCode AI 설정
└── install.sh               # 설치/업데이트 스크립트
```

## install.sh 기능

- **자동 모드 감지**: 첫 설치 vs 업데이트 자동 판단
- **아키텍처 감지**: Apple Silicon / Intel 자동 대응
- **멱등성**: 여러 번 실행해도 안전
- **Force 모드**: `./install.sh --force`로 전체 재설치

### 설치되는 것들

1. Homebrew + 개발 도구들
2. WezTerm Nightly
3. D2Coding Nerd Font
4. Miniconda + UV (Python)
5. Fish + Fisher 플러그인
6. LazyVim + 플러그인
7. OpenCode + MCP 서버 (Serena, Context7 등)

## 주요 단축키

### Neovim (LazyVim)
- `<Space>` - Leader
- `<Space>ff` - 파일 찾기
- `<Space>fg` - 텍스트 검색
- `<Space>e` - 파일 탐색기
- `<Space>gg` - LazyGit

### WezTerm
- `Cmd+D` - 수직 분할
- `Cmd+Shift+D` - 수평 분할
- `Cmd+H/J/K/L` - 패널 이동

## 업데이트

```bash
cd ~/dotfiles
./install.sh  # UPDATE 모드로 자동 실행
```

## 민감한 정보

`fish/.config/fish/config.local.fish`에 API 키 등 저장 (gitignore됨)

```fish
# config.local.fish 예시
set -gx ANTHROPIC_API_KEY "sk-..."
set -gx OPENAI_API_KEY "sk-..."
```

## 라이선스

MIT
