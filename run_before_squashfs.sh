#!/bin/bash

# Made by Fernando "maroto"
# Run anything in the filesystem right before being "mksquashed"

script_path=$(readlink -f ${0%/*})
work_dir=work

# Adapted from AIS. An excellent bit of code!
arch_chroot(){
    arch-chroot $script_path/${work_dir}/airootfs /bin/bash -c "${1}"
}  

do_merge(){

arch_chroot "

sed -i 's/#\(en_US\.UTF-8\)/\1/' /etc/locale.gen
locale-gen
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
usermod -s /usr/bin/bash root
cp -aT /etc/skel/ /root/
chmod 700 /root
useradd -m -p \"\" -g users -G 'sys,rfkill,wheel' -s /bin/bash liveuser
git clone https://github.com/endeavouros-team/liveuser-desktop-settings.git
cd liveuser-desktop-settings
rm -R /home/liveuser/.config
cp -R .config /home/liveuser/
chown -R liveuser:users /home/liveuser/.config
cp user_pkglist.txt /home/liveuser/
chown liveuser:users /home/liveuser/user_pkglist.txt
rm /home/liveuser/.bashrc
cp .bashrc /home/liveuser/
chown liveuser:users /home/liveuser/.bashrc
cp -R community_editions /home/liveuser/
chown -R liveuser:users /home/liveuser/community_editions
cp LICENSE /home/liveuser/
cd .. 
rm -R liveuser-desktop-settings
chmod 755 /etc/sudoers.d
mkdir -p /media
chmod 755 /media
chmod 440 /etc/sudoers.d/g_wheel
chown 0 /etc/sudoers.d
chown 0 /etc/sudoers.d/g_wheel
chown root:root /etc/sudoers.d
chown root:root /etc/sudoers.d/g_wheel
chmod 755 /etc
sed -i 's/#\(PermitRootLogin \).\+/\1yes/' /etc/ssh/sshd_config
sed -i 's/#Server/Server/g' /etc/pacman.d/mirrorlist
sed -i 's/#\(Storage=\)auto/\1volatile/' /etc/systemd/journald.conf
sed -i 's/#\(HandleSuspendKey=\)suspend/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleHibernateKey=\)hibernate/\1ignore/' /etc/systemd/logind.conf
sed -i 's/#\(HandleLidSwitch=\)suspend/\1ignore/' /etc/systemd/logind.conf
systemctl enable NetworkManager.service vboxservice.service vmtoolsd.service vmware-vmblock-fuse.service systemd-timesyncd
systemctl set-default multi-user.target

cp -rf /usr/share/mkinitcpio/hook.preset /etc/mkinitcpio.d/linux.preset
sed -i 's?%PKGBASE%?linux?' /etc/mkinitcpio.d/linux.preset

pacman-key --init
pacman-key --add /usr/share/pacman/keyrings/endeavouros.gpg && sudo pacman-key --lsign-key 497AF50C92AD2384C56E1ACA003DB8B0CB23504F
pacman-key --populate
pacman-key --refresh-keys
pacman -Syy
sed -i 's|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"$|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 nowatchdog\"|' /etc/default/grub
sed -i 's?GRUB_DISTRIBUTOR=.*?GRUB_DISTRIBUTOR=\"EndeavourOS\"?' /etc/default/grub
sed -i 's?\#GRUB_THEME=.*?GRUB_THEME=\/boot\/grub\/themes\/EndeavourOS\/theme.txt?g' /etc/default/grub
echo 'GRUB_DISABLE_SUBMENU=y' >> /etc/default/grub
rm /boot/grub/grub.cfg
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/cleaner_script.sh
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/chrooted_cleaner_script.sh
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/calamares_switcher
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/pacstrap_calamares
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/update-mirrorlist
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/calamares_for_testers
wget https://raw.githubusercontent.com/endeavouros-team/install-scripts/master/prepare-calamares
chmod +x cleaner_script.sh chrooted_cleaner_script.sh calamares_switcher pacstrap_calamares update-mirrorlist calamares_for_testers prepare-calamares
mv cleaner_script.sh chrooted_cleaner_script.sh calamares_switcher update-mirrorlist pacstrap_calamares calamares_for_testers prepare-calamares /usr/bin/
wget https://raw.githubusercontent.com/endeavouros-team/liveuser-desktop-settings/master/dconf/xed.dconf
dbus-launch dconf load / < xed.dconf
sudo -H -u liveuser bash -c 'dbus-launch dconf load / < xed.dconf'
rm xed.dconf
chmod -R 700 /root
chown root:root -R /root
chown root:root -R /etc/skel
chmod 644 /usr/share/endeavouros/*.png
rm -rf /usr/share/backgrounds/xfce/xfce-verticals.png
ln -s /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png /usr/share/backgrounds/xfce/xfce-verticals.png
chsh -s /bin/bash"
}

#################################
########## STARTS HERE ##########
#################################

do_merge
