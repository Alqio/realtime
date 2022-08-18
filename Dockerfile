FROM ubuntu:20.04

SHELL ["/bin/bash", "-c"]

RUN apt-get update

RUN apt-cache policy | grep universe

RUN apt-get install software-properties-common -y
RUN add-apt-repository universe

RUN apt-get update && apt-get install curl gnupg lsb-release -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg

RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(source /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && apt install -y \
      build-essential \
      cmake \
      git \
      python3-colcon-common-extensions \
      python3-flake8 \
      python3-pip \
      python3-pytest-cov \
      python3-rosdep \
      python3-setuptools \
      python3-vcstool \
      wget

RUN python3 -m pip install -U \
      flake8-blind-except \
      flake8-builtins \
      flake8-class-newline \
      flake8-comprehensions \
      flake8-deprecated \
      flake8-docstrings \
      flake8-import-order \
      flake8-quotes \
      pytest-repeat \
      pytest-rerunfailures \
      pytest \
      setuptools
ENV DEBIAN_FRONTEND noninteractive

RUN RTI_NC_LICENSE_ACCEPTED=yes apt-get install -y rti-connext-dds-5.3.1

RUN mkdir -p /root/ros2_galactic/src
WORKDIR /root/ros2_galactic
RUN wget https://raw.githubusercontent.com/ros2/ros2/galactic/ros2.repos
RUN vcs import src < ros2.repos

RUN rosdep init
RUN rosdep update
RUN cd /opt/rti.com/rti_connext_dds-5.3.1/resource/scripts && source ./rtisetenv_x64Linux3gcc5.4.0.bash; cd - && rosdep install --from-paths src --ignore-src -y --skip-keys "fastcdr urdfdom_headers"

RUN cd /opt/rti.com/rti_connext_dds-5.3.1/resource/scripts && source ./rtisetenv_x64Linux3gcc5.4.0.bash; cd - && colcon build --symlink-install

# Copy ROS workspace
# Build ROS packages
# RUN source /opt/ros/galactic/setup.bash && colcon build --symlink-install

WORKDIR /
# Copy entrypoint
COPY entrypoint.sh /

# ENTRYPOINT ["./entrypoint.sh"]