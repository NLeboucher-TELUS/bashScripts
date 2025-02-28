# bashScripts

A collection of useful bash functions and utilities for enhanced command-line productivity.

## Features

- **Proxy Management**: Easily set/unset proxy settings (both temporary and permanent)
- **Weather Information**: Get current weather for any city (requires OpenWeather API key)
- **File Operations**: Enhanced commands for file manipulation and navigation
- **Git Utilities**: Streamlined git operations
- **Kubernetes Helpers**: Simplified pod management and port forwarding
- **GCP Tools**: Easy project switching and management
- **AI Integration**: CLI interface for OpenAI API queries
- **Command Translation**: Natural language to bash command conversion

## Setup

1. Clone this repository:
```bash
git clone https://github.com/yourusername/bashScripts.git ~/Documents/github/bashScripts
```

2. Add to your `.bashrc`:
```bash
if [ -f ~/Documents/github/bashScripts/bashrc ]; then
    source ~/Documents/github/bashScripts/bashrc
fi
```

3. Set required environment variables in `env`:
- `OPENWEATHER_API_KEY`: For weather functions
- `OPENAI_API_KEY`: For AI features
- Other custom environment variables

## Key Functions

### Proxy Management
- `proxy`: Set proxy variables for current session
- `noproxy`: Unset proxy variables
- `proxyhard`: Set permanent system proxy
- `noproxyhard`: Unset permanent system proxy

### Navigation & File Operations
- `mkcd`: Create and enter directory
- `extract`: Smart archive extraction
- `hereis`: Enhanced file search
- `watch`: Monitor command output

### Git Operations
- `clone`: Clone repository to ~/Documents/github/
- `addcommitpush`: Combine git add, commit, and push
- `cdg`: Change to GitHub project directory
- `codeg`: Open GitHub project in VS Code

### AI & Command Line
- `ai`: Query OpenAI API
- `cli`: Convert natural language to bash commands
  - Usage: `cli "list all files"`
  - Options: `-y` (auto-execute), `-n` (show only)

### Helper Functions
- `weather [city]`: Show current weather
- `help [command]`: Show detailed help for commands
- `usage`: Show disk usage
- `hist`: Search command history

## Documentation

Use `help` to see available commands:
```bash
help                    # List all commands
help <command>          # Show detailed help for specific command
```

## Requirements

- Bash shell
- curl
- jq (for JSON parsing)
- OpenWeather API key (for weather function)
- OpenAI API key (for AI features)

## Notes

- Custom functions preserve command history
- Proxy settings are configurable in the `proxy` file
- Environment variables can be customized in `env`
