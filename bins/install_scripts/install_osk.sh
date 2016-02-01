#! /bin/bash

OSK_VERSION="Version 0.1"

if [ "$#" == "0" ];then

	echo -e ""
	echo -e "----------------------------------"
	echo -e " Open Foris SAR Toolkit, version ${OSK_VERSION}"
	echo -e " Install script"
	echo -e " Developed by: Food and Agriculture Organization of the United Nations, Rome"
#	echo -e " Author: Andreas Vollrath"
	echo -e "----------------------------------"
	echo -e ""
	export OSK_HOME=/usr/local/lib/osk

elif [ "$#" == "1" ];then

	echo -e ""
	echo -e "----------------------------------"
	echo -e " Open Foris SAR Toolkit, version ${OSK_VERSION}"
	echo -e " Install script"
	echo -e " Developed by: Food and Agriculture Organization of the United Nations, Rome"
#	echo -e " Author: Andreas Vollrath"
	echo -e "----------------------------------"
	echo -e ""
	export OSK_HOME=$1

else 

	echo -e ""
	echo -e "----------------------------------"
	echo -e " Open Foris SAR Toolkit, version ${OSK_VERSION}"
	echo -e " Install script"
	echo -e " Developed by: Food and Agriculture Organization of the United Nations, Rome"
#	echo -e " Author: Andreas Vollrath"
	echo -e "----------------------------------"
	echo -e ""

	echo -e " syntax: install_osk <installation_folder>"
	echo -e ""
	echo -e " description of input parameters:"
	echo -e " installation_folder		(output) path to installation folder of OSK"
	exit 1
fi

#----------------------------------
# 1 Adding extra repositories
#----------------------------------
## I GIS packages from ubuntugis (unstable)
add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable


## II InSAR Packages Antonio Valentinos eotools 
#add-apt-repository -y ppa:a.valentino/eotools

## III Java Official Packages
add-apt-repository -y ppa:webupd8team/java

## Enable multiverse for unrar
add-apt-repository -y "deb http://archive.ubuntu.com/ubuntu/ $(lsb_release -sc) main multiverse"

#QGIS for 14.04
# add lines to sources
#if grep -q "qgis.org/ubuntugis" /etc/apt/sources.list;then 
#	echo "Yeah, you are QGIS user, nice!"
#else
#	echo "deb http://qgis.org/ubuntugis $(lsb_release -sc) main" >> /etc/apt/sources.list
#	echo "deb-src http://qgis.org/ubuntugis $(lsb_release -sc) main" >> /etc/apt/sources.list
	# add key
#	apt-key adv --keyserver keyserver.ubuntu.com --recv-key 3FF5FFCAD71472C4
#fi

#------------------------------------------------------------------
# 2 run update to load new packages and upgrade all installed ones
#------------------------------------------------------------------
apt-get update -y
apt-get upgrade -y 


#------------------------------------------------------------------
# 3 install packages
#------------------------------------------------------------------
# Gis Packages
#apt-get install --yes qgis gdal-bin libgdal-dev python-gdal saga libsaga-dev python-saga otb-bin libotb-dev libotb-ice libotb-ice-dev monteverdi2 python-otb geotiff-bin libgeotiff-dev gmt libgmt-dev dans-gdal-scripts
#libqgis-dev (problems with grass 7)

apt-get install --yes gdal-bin libgdal-dev python-gdal saga libsaga-dev python-saga geotiff-bin libgeotiff-dev dans-gdal-scripts

## Spatial-Database Spatialite
apt-get install --yes spatialite-bin spatialite-gui #pgadmin3 postgresql postgis

# Dependencies for ASF Mapready
apt-get install --yes libcunit1-dev libfftw3-dev libshp-dev libgeotiff-dev libtiff4-dev libtiff5-dev libproj-dev gdal-bin flex bison libgsl0-dev gsl-bin git libglade2-dev libgtk2.0-dev libgdal-dev pkg-config

## Java official
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections \
    && echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections # Enable silent install of Java
apt-get install --yes oracle-java8-installer oracle-java8-set-default

## Python libraries
apt-get install --yes python-scipy python-h5py 
#python-pyresample  --> needs grass devel. repo

# Dependencies for PolSARPro
#apt-get install --yes bwidget itcl3 itk3 iwidgets4 libtk-img 

# Further tools (i.e. Aria for automated ASF download, unrar for unpacking, parallel for parallelization of processing)
apt-get install --yes aria2 unrar parallel xml-twig-tools

#------------------------------------------------------------------
# 3 Download & Install non-repository Software and OSK
#------------------------------------------------------------------

#-------------------------------------
# get OSK from github repository
if [ -z "$OSK_GIT_URL" ]; then export OSK_GIT_URL=https://github.com/BuddyVolly/OpenSARKit; fi
mkdir -p ${OSK_HOME}
cd ${OSK_HOME}

OSK_VERSION=0.1-beta

# write a preliminary source file
echo '#! /bin/bash' > ${OSK_HOME}/OpenSARKit_source.bash
echo "" >> ${OSK_HOME}/OpenSARKit_source.bash

echo "export OSK_VERSION=${OSK_VERSION}" >> ${OSK_HOME}/OpenSARKit_source.bash
echo "export AUTHOR_1=\"Andreas Vollrath\"" >> ${OSK_HOME}/OpenSARKit_source.bash
echo "export CONTACT_1=\"andreas.vollrath@fao.org\"" >> ${OSK_HOME}/OpenSARKit_source.bash

echo '# Support script to source the original programs' >> ${OSK_HOME}/OpenSARKit_source.bash
echo "export OSK_HOME=${OSK_HOME}" >> ${OSK_HOME}/OpenSARKit_source.bash

echo '# Folder of OpenSARKit scripts and workflows' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export OPENSARKIT=${OSK_HOME}/OpenSARKit' >> ${OSK_HOME}/OpenSARKit_source.bash

echo '# source auxiliary Spatialite database' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export DB_GLOBAL=${OSK_HOME}/Database/global_info.sqlite' >> ${OSK_HOME}/OpenSARKit_source.bash	 

echo '# source lib-functions' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'source ${OPENSARKIT}/lib/gdal_helpers' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'source ${OPENSARKIT}/lib/saga_helpers' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'source ${OPENSARKIT}/lib/s1_helpers' >> ${OSK_HOME}/OpenSARKit_source.bash

echo '# source workflows/graphs' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export NEST_GRAPHS=${OPENSARKIT}/workflows/NEST' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export SNAP_GRAPHS=${OPENSARKIT}/workflows/SNAP' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export ASF_CONF=${OPENSARKIT}/workflows/ASF' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export POLSAR_CONF=${OPENSARKIT}/workflows/POLSAR' >> ${OSK_HOME}/OpenSARKit_source.bash
# 
echo '# export bins' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export SNAP_BIN=${OPENSARKIT}/bins/SNAP' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export ASF_BIN=${OPENSARKIT}/bins/ASF' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export KC_BIN=${OPENSARKIT}/bins/KC' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export REMOTE_BIN=${OPENSARKIT}/bins/Remote_scripts' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export DOWNLOAD_BIN=${OPENSARKIT}/bins/Download' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export PYTHON_BIN=${OPENSARKIT}/python' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export GDAL_BIN=${OPENSARKIT}/bins/GDAL' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export SAGA_BIN=${OPENSARKIT}/bins/SAGA' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export RSGISLIB_BIN=${OPENSARKIT}/bins/RSGISLIB' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export PROGRAMS=${OSK_HOME}/Programs' >> ${OSK_HOME}/OpenSARKit_source.bash

# get OpenSARKit from github
git clone $OSK_GIT_URL
#-------------------------------------


# install dependend Software
mkdir -p ${OSK_HOME}/Programs
cd ${OSK_HOME}/Programs

#-------------------------------------
# Install ASF Mapready

# check if installed
if [ `which asf_mapready | wc -c` -gt 0 ];then 

	AOI_EXE=`dirname \`which asf_mapready\``
	echo 'export AOI_EXE=${AOI_EXE}' >> ${OSK_HOME}/OpenSARKit_source.bash

else

	#git clone https://github.com/asfadmin/ASF_MapReady
	wget https://github.com/asfadmin/ASF_MapReady/archive/3.6.6-117.tar.gz
	tar -xzvf ${OSK_HOME}/Programs/3.6.6-117.tar.gz
	rm -f ${OSK_HOME}/Programs/3.6.6-117.tar.gz
	cd ASF_MapReady-3.6.6-117
	./configure --prefix=${OSK_HOME}/Programs/ASF_bin
	make
	make install
	echo 'export ASF_EXE=${PROGRAMS}/ASF_bin/bin' >> ${OSK_HOME}/OpenSARKit_source.bash
fi 
#-------------------------------------

#-------------------------------------
# Insatll PolsARPro
#if [ `which alos_header.exe | wc -c` -gt 0 ];then 

#	POLSAR_PRE=`dirname \`which alos_header.exe\``
#	cd ${POLSAR_PRE}/../
#	POLSAR=`pwd`
#	echo 'export POLSAR=${POLSAR}' >> ${OSK_HOME}/OpenSARKit_source.bash
#	echo 'export POLSAR_BIN=${POLSAR}/data_import:${POLSAR}/data_convert:${POLSAR}/speckle_filter:${POLSAR}/bmp_process:${POLSAR}/tools' >> ${OSK_HOME}/OpenSARKit_source.bash

#else

	# PolSARPro
#	mkdir -p ${OSK_HOME}/Programs/PolSARPro504
#	cd ${OSK_HOME}/Programs/PolSARPro504
#	wget https://earth.esa.int/documents/653194/1960708/PolSARpro_v5.0.4_Linux_20150607
#	unrar x PolSARpro_v5.0.4_Linux_20150607
#	cd Soft
#	bash Compil_PolSARpro_v5_Linux.bat 
#	POLSAR=`pwd` 
#	echo 'export POLSAR=${PROGRAMS}/PolSARPro504/Soft' >> ${OSK_HOME}/OpenSARKit_source.bash
#	echo 'export POLSAR_BIN=${POLSAR}/data_import:${POLSAR}/data_convert:${POLSAR}/speckle_filter:${POLSAR}/bmp_process:${POLSAR}/tools' >> ${OSK_HOME}/OpenSARKit_source.bash
#fi
#-------------------------------------

#-------------------------------------
# Insatll SNAP
# check if installed
if [ `which snap | wc -c` -gt 0 ];then 

	SNAP=`dirname \`which gpt\``
	echo 'export SNAP=${SNAP}' >> ${OSK_HOME}/OpenSARKit_source.bash
	echo 'export SNAP_EXE=${SNAP}/bin/gpt'  >> ${OSK_HOME}/OpenSARKit_source.bash
else
	cd ${OSK_HOME}/Programs/
	#wget http://sentinel1.s3.amazonaws.com/1.0/s1tbx_1.1.1_Linux64_installer.sh
	#sh s1tbx_1.1.1_Linux64_installer.sh -q -overwrite
	#rm -f s1tbx_1.1.1_Linux64_installer.sh

	wget http://step.esa.int/downloads/2.0/esa-snap_all_unix_2_0_2.sh
	sh esa-snap_all_unix_2_0_2.sh -q -overwrite
	rm -f esa-snap_all_unix_2_0_2.sh
	echo 'export SNAP=/usr/local/snap' >> ${OSK_HOME}/OpenSARKit_source.bash
	#echo 'export SNAP=${HOME}/snap' >> ${OSK_HOME}/OpenSARKit_source.bash
	echo 'export SNAP_EXE=${SNAP}/bin/gpt'  >> ${OSK_HOME}/OpenSARKit_source.bash
fi

# update SNAP - not necessary at the moment (1.2.2016)
#snap --nosplash --modules --refresh --install org.csa.rstb.rstb.op.polarimetric.tools org.esa.s2tbx.s2tbx.s2msi.reader org.esa.s3tbx.s3tbx.landsat.reader org.esa.s3tbx.s3tbx.sentinel3.reader org.esa.s1tbx.s1tbx.kit org.esa.s3tbx.s3tbx.spot.vgt.reader org.esa.s3tbx.s3tbx.sentinel3.reader.ui org.esa.s1tbx.s1tbx.commons org.esa.s3tbx.s3tbx.aatsr.sst.ui org.esa.s1tbx.s1tbx.op.analysis.ui org.esa.snap.seadas.seadas.reader.ui org.esa.s3tbx.s3tbx.proba.v.reader org.esa.s2tbx.sen2cor org.esa.s1tbx.s1tbx.op.feature.extraction org.esa.s3tbx.s3tbx.merisl3.reader org.jlinda.jlinda.nest org.esa.s2tbx.s2tbx.spot.reader org.esa.s3tbx.s3tbx.meris.smac org.esa.smostbx.smos.tools org.esa.s1tbx.s1tbx.op.sar.processing org.esa.s2tbx.s2tbx.rapideye.reader org.esa.smostbx.smos.gui org.esa.s1tbx.s1tbx.rcp org.csa.rstb.rstb.op.classification.ui org.esa.s3tbx.s3tbx.atsr.reader org.esa.s1tbx.s1tbx.op.insar org.esa.s1tbx.s1tbx.op.calibration.ui org.esa.s2tbx.s2tbx.jp2.reader org.csa.rstb.rstb.kit org.esa.smostbx.smos.reader org.esa.s1tbx.s1tbx.op.utilities.ui org.esa.snap.seadas.seadas.reader org.esa.s1tbx.s1tbx.op.ocean.ui org.esa.smostbx.smos.kit org.esa.s3tbx.s3tbx.alos.reader org.esa.s1tbx.s1tbx.op.utilities org.jlinda.jlinda.core org.esa.s1tbx.s1tbx.op.feature.extraction.ui org.esa.s3tbx.s3tbx.avhrr.reader org.jlinda.jlinda.nest.ui org.esa.s3tbx.s3tbx.modis.reader org.csa.rstb.rstb.op.classification org.csa.rstb.rstb.op.polarimetric.tools.ui org.esa.s2tbx.lib.openjpeg org.esa.s3tbx.s3tbx.slstr.pdu.stitching.ui org.esa.s3tbx.s3tbx.flhmci org.esa.s2tbx.s2tbx.commons org.esa.s3tbx.s3tbx.aatsr.sst org.esa.smostbx.smos.ee2netcdf.ui org.esa.s3tbx.s3tbx.meris.ops org.esa.s3tbx.s3tbx.meris.radiometry org.esa.smostbx.smos.dgg org.esa.s3tbx.s3tbx.kit org.esa.s3tbx.s3tbx.meris.radiometry.ui org.esa.smostbx.smos.lsmask org.esa.s1tbx.s1tbx.op.sar.processing.ui org.esa.s3tbx.s3tbx.chris.reader org.esa.s2tbx.s2tbx.deimos.reader org.esa.s1tbx.s1tbx.op.sentinel1.ui org.esa.s1tbx.s1tbx.op.sentinel1 org.esa.s1tbx.s1tbx.op.insar.ui org.esa.smostbx.smos.ee2netcdf org.esa.s3tbx.s3tbx.slstr.pdu.stitching org.esa.s2tbx.s2tbx.sta.adapters.help org.esa.s2tbx.s2tbx.kit org.esa.s1tbx.s1tbx.io org.esa.s3tbx.s3tbx.meris.cloud org.esa.s1tbx.s1tbx.op.calibration org.esa.s3tbx.s3tbx.flhmci.ui

#snap --nosplash --modules --refresh --enable org.esa.s1tbx.s1tbx.kit org.openide.util.enumerations org.openide.compat org.netbeans.core.multiview org.netbeans.api.visual jcl.over.slf4j org.openide.options org.netbeans.core.osgi org.netbeans.modules.netbinox org.netbeans.api.search org.netbeans.modules.uihandler org.netbeans.modules.spi.actions org.netbeans.libs.javafx org.esa.s3tbx.s3tbx.kit org.jdesktop.layout org.netbeans.lib.uihandler org.netbeans.libs.jsr223 
#-------------------------------------

#-------------------------------------
## Adding executalble to path for CL availability
echo '#export to Path' >> ${OSK_HOME}/OpenSARKit_source.bash
echo 'export PATH=$PATH:${PYTHON_BIN}:${RSGISLIB_BIN}:${ASF_BIN}:${POLSAR_BIN}:${SAGA_BIN}:${SNAP_BIN}:${GDAL_BIN}:${DOWNLOAD_BIN}:${ASF_EXE}:${SNAP}:${KC_BIN}:${REMOTE_BIN}' >> ${OSK_HOME}/OpenSARKit_source.bash

# Update global environment variables"
mv ${OSK_HOME}/OpenSARKit_source.bash /etc/profile.d/OpenSARKit.sh
chmod -R 755 ${OSK_HOME}
source /etc/profile.d/OpenSARKit.sh
#-------------------------------------


#------------------------------------------------------------------
# 3 Download the additional Database
#------------------------------------------------------------------

mkdir -p ${OSK_HOME}/Database
cd ${OSK_HOME}/Database
wget https://www.dropbox.com/s/58cnjj8xymzkbac/global_info.sqlite?dl=0
mv global_info.sqlite?dl=0 global_info.sqlite

echo "--------------------------------"
echo " Installation of OFST completed"
echo "--------------------------------"
