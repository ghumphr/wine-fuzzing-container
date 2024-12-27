FROM aflplusplus/aflplusplus:latest
ENV USER=root
ENV DEBIAN_FRONTEND=noninteractive
ENV AFL_PATH=/AFLplusplus
WORKDIR /root
RUN apt update -y

# Install XFCE, VNC server, dbus-x11, and xfonts-base
RUN apt update -y && apt install -y --no-install-recommends xfce4 xfce4-goodies tigervnc-standalone-server dbus-x11 xfonts-base software-properties-common

# Install Wine
RUN dpkg --add-architecture i386
RUN apt-add-repository universe
RUN apt update -y
RUN wget https://dl.winehq.org/wine-builds/winehq.key && apt-key add winehq.key && apt-add-repository -y 'https://dl.winehq.org/wine-builds/ubuntu/' && apt update -y && apt install -y winehq-devel winetricks

# Install Python for Windows
RUN mkdir /winpython; cd /winpython && wget https://www.python.org/ftp/python/3.12.4/python-3.12.4-embed-amd64.zip && unzip python-3.12.4-embed-amd64.zip

# Install Frida on Windows
RUN cd /winpython && PTH=`ls *_pth` && cp $PTH $PTH.bak && sed 's/#import/import/' < $PTH.bak > $PTH && wget 'https://bootstrap.pypa.io/get-pip.py' && wine python get-pip.py && wine Scripts/pip.exe install setuptools && wine Scripts/pip.exe install frida-tools
RUN cd /winpython/Scripts && wget "https://github.com/frida/frida/releases/download/16.5.9/frida-server-16.5.9-windows-x86.exe.xz" && xz -d frida-server-16.5.9-windows-x86.exe.xz && mv frida-server-16.5.9-windows-x86.exe frida-server-x86.exe && wget "https://github.com/frida/frida/releases/download/16.5.9/frida-server-16.5.9-windows-x86_64.exe.xz" && xz -d frida-server-16.5.9-windows-x86_64.exe.xz && mv frida-server-16.5.9-windows-x86_64.exe frida-server-x86_64.exe
RUN cd /winpython/Scripts && wget "https://github.com/frida/frida/releases/download/16.5.9/frida-gadget-16.5.9-windows-x86.dll.xz" && xz -d frida-gadget-16.5.9-windows-x86.dll.xz && mv frida-gadget-16.5.9-windows-x86.dll frida-gadget-x86.dll && wget "https://github.com/frida/frida/releases/download/16.5.9/frida-gadget-16.5.9-windows-x86_64.dll.xz" && xz -d frida-gadget-16.5.9-windows-x86_64.dll.xz && mv frida-gadget-16.5.9-windows-x86_64.dll frida-gadget-x86_64.dll

# Install Screen
RUN apt install -y screen

# Install pefile
RUN pip install pefile

# Install Frida (native)
RUN pip install frida frida-tools

# Get the Fuzz with Wine demo
RUN cd /root && git clone 'https://github.com/AFLplusplus/Fuzz-With-Wine-Demo.git' && cd Fuzz-With-Wine-Demo && make && cp afl-wine-trace /AFLplusplus

# Install Fpicker
RUN cd /root && git clone 'https://github.com/ttdennis/fpicker.git' && cd fpicker && \
	wget 'https://github.com/frida/frida/releases/download/16.5.9/frida-core-devkit-16.5.9-linux-x86_64.tar.xz' && \
	xz -d < frida-core-devkit-16.5.9-linux-x86_64.tar.xz | tar xvf - && \
	cp libfrida-core.a libfrida-core-linux.a && \
	cp frida-core.h frida-core-linux.h && \
	make fpicker-linux 

# Free apt cache
RUN apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose VNC port
EXPOSE 5901

# Expose frida-server ports (??)
EXPOSE 24932
EXPOSE 24964

# List the contents of the /root directory
RUN ls -a /root


