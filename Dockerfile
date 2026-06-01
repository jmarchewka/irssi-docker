FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
    irssi \
    openssh-server \
    tmux \
    && rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash -g irc irc

# SSH hardening: no root, no passwords
RUN mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo "PasswordAuthentication no" >> /etc/ssh/sshd_config && \
    echo "AuthorizedKeysFile .ssh/authorized_keys" >> /etc/ssh/sshd_config

# Prepare .ssh dir — key is injected at build or via volume
RUN mkdir -p /home/irc/.ssh && \
    chmod 700 /home/irc/.ssh && \
    chown -R irc:irc /home/irc/.ssh

# Drop into tmux+irssi on login
RUN echo 'if [ -z "$TMUX" ]; then tmux new-session -A -s irc "irssi"; fi' >> /home/irc/.bashrc

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
