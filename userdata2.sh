#!/bin/bash
sudo apt update
sudo apt install -y apache2

# Install the AWS CLI
sudo apt install -y awscli

sudo tee /var/www/html/index.html > /dev/null <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Server2</title>
    <style>
        body {
            margin: 0;
            height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            font-family: Arial, sans-serif;
            background-color: #e8f7ff; /* Light blue background */
        }
        h1 {
            font-size: 2.5rem;
            color: #005f99; /* Dark blue text */
        }
    </style>
</head>
<body>
    <h1>Welcome to Webserver 2</h1>
</body>
</html>
EOF

# Start Apache and enable it on boot
sudo systemctl start apache2
sudo systemctl enable apache2
