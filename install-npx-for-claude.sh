#!/bin/bash

# Check if file already exists
if [ -f /usr/local/bin/npx-for-claude ]; then
    echo "Error: /usr/local/bin/npx-for-claude already exists"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 1
    fi
fi

# Create npx-for-claude script
cat << 'EOF' | sudo tee /usr/local/bin/npx-for-claude > /dev/null
#!/bin/bash
export PATH="$HOME/.config/nvm/versions/node/v22.16.0/bin:$PATH"
exec npx "$@"
EOF

# Make it executable
sudo chmod +x /usr/local/bin/npx-for-claude

echo "npx-for-claude has been created at /usr/local/bin/npx-for-claude"