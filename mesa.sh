cd /data/data/com.termux/files/home
rm -rf mesa
rm -rf .local/share/meson/native/mesa
mkdir -p .local/share/meson/native
mkdir mesa
cd mesa
mkdir files
yes|pkg update
yes|pkg install binutils bison flex git ndk-multilib ninja patchelf python wget zip
yes|/data/data/com.termux/files/usr/bin/python3 -m pip install --upgrade pip
yes|pip3 install mako meson
wget https://raw.githubusercontent.com/edisionnano/Freedreno_Turnip_Termux/main/mesa -P /data/data/com.termux/files/home/.local/share/meson/native
libdrm=$(curl -s https://archlinuxarm.org/packages/aarch64/libdrm|grep -oP '(?<=href=").*(?="\>Download\<)')
wget -O libdrm.tar.xz $libdrm
tar -C files -xvf libdrm.tar.xz usr
rm libdrm.tar.xz
sed -i 's#prefix=#&/data/data/com.termux/files/home/mesa/files#g' files/usr/lib/pkgconfig/libdrm.pc
git clone --depth 1 --branch main https://gitlab.freedesktop.org/mesa/mesa.git
cd mesa
meson build-android-aarch64 --native-file mesa -Dbuildtype=release -Dplatforms=android -Dplatform-sdk-version=32 -Dandroid-stub=true -Dgallium-drivers= -Dvulkan-drivers=freedreno -Dfreedreno-kgsl=true -Dcpp_rtti=false -Db_lto=true
ninja -C build-android-aarch64
