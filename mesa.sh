clear
soname=$(ls /system/vendor/lib64/hw/|grep vulkan)
cd /data/data/com.termux/files/home
rm -rf mesa
rm -rf .local/share/meson/native/mesa
mkdir -p mesa/magisk/META-INF/com/google/android
mkdir -p mesa/magisk/system/vendor/lib64/hw
curl -s https://raw.githubusercontent.com/edisionnano/Freedreno_Turnip_Termux/main/update-binary > mesa/magisk/META-INF/com/google/android/update-binary
echo "#MAGISK" > mesa/magisk/META-INF/com/google/android/updater-script
cd mesa
mkdir files
yes|pkg up
yes|pkg i binutils bison flex git ndk-multilib ninja patchelf python wget zip
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
version=$(cat VERSION)
echo -e "id=turnip\nname=Freedreno Turnip\nversion=$version\nversionCode=1\nauthor=Samantas5855\ndescription=Open Source Vulkan driver for Adreno GPUs, part of the MESA project" > ../magisk/module.prop
wget https://raw.githubusercontent.com/edisionnano/Freedreno_Turnip_Termux/main/timespec_get.diff
git apply timespec_get.diff
meson build-android-aarch64 --native-file mesa -Dbuildtype=release -Dplatforms=android -Dplatform-sdk-version=32 -Dandroid-stub=true -Dgallium-drivers= -Dvulkan-drivers=freedreno -Dfreedreno-kgsl=true -Dcpp_rtti=false -Db_lto=true
ninja -C build-android-aarch64
patchelf --set-soname $soname build-android-aarch64/src/freedreno/vulkan/libvulkan_freedreno.so
mv build-android-aarch64/src/freedreno/vulkan/libvulkan_freedreno.so ../magisk/system/vendor/lib64/hw/$soname
cd ../magisk
zip -r -q turnip.zip *
mv turnip.zip /storage/emulated/0
cd /data/data/com.termux/files/home
rm -rf mesa
clear
printf "Compilation finished, flash the file turnip.zip located at your home folder using Magisk Manager.\n"
