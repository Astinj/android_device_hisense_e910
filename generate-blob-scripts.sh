#!/usr/bin/env bash

# Copyright (C) 2010 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

MANUFACTURERNAME=hisense
DEVICENAME=e910

FILES=$(cat <<EOF
/system/etc/AudioFilter.csv
/system/lib/egl/libEGL_adreno200.so
/system/lib/egl/libGLESv1_CM_adreno200.so
/system/lib/egl/libGLESv2_adreno200.so
/system/lib/hw/copybit.msm7k.so
/system/lib/libgsl.so
/system/lib/libril-qc-1.so
/system/lib/liboncrpc.so
/system/lib/libdsm.so
/system/lib/libqueue.so
/system/lib/libcm.so
/system/lib/libdiag.so
/system/lib/libmmgsdilib.so
/system/lib/libgsdi_exp.so
/system/lib/libgstk_exp.so
/system/lib/libwms.so
/system/lib/libnv.so
/system/lib/libwmsts.so
/system/lib/libpbmlib.so
/system/lib/libril-qcril-hook-oem.so
/system/lib/libdss.so
/system/lib/libqmi.so
/system/lib/liboem_rapi.so
/system/bin/qmuxd
/system/lib/libmmjpeg.so
/system/lib/libmmipl.so
/system/lib/libmm-adspsvc.so
/system/lib/libOmxH264Dec.so
/system/lib/libOmxMpeg4Dec.so
/system/lib/libOmxVidEnc.so
/system/lib/libOmxWmvDec.so
/system/etc/init.qcom.bt.sh
/system/bin/hci_qcomm_init
/system/lib/hw/sensors.default.so
/system/lib/libauth.so
/system/lib/libqmi.so
/system/lib/libdsutils.so
/system/lib/libqmiservices.so
/system/lib/libidl.so
/system/lib/libdsi_netctrl.so
/system/lib/libnetmgr.so
/system/lib/libqdp.so
/system/lib/libaudioeq.so
EOF
)

for FILESTYLE in extract unzip
do
  (
  echo '#!/bin/sh'
  echo
  echo '# Copyright (C) 2010 The Android Open Source Project'
  echo '#'
  echo '# Licensed under the Apache License, Version 2.0 (the "License");'
  echo '# you may not use this file except in compliance with the License.'
  echo '# You may obtain a copy of the License at'
  echo '#'
  echo '#      http://www.apache.org/licenses/LICENSE-2.0'
  echo '#'
  echo '# Unless required by applicable law or agreed to in writing, software'
  echo '# distributed under the License is distributed on an "AS IS" BASIS,'
  echo '# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.'
  echo '# See the License for the specific language governing permissions and'
  echo '# limitations under the License.'
  echo
  echo '# This file is generated by device/hisense/e910/generate-blob-scripts.sh - DO NOT EDIT'
  echo
  echo DEVICE=$DEVICENAME
  echo MANUFACTURER=$MANUFACTURERNAME
  echo
  echo 'mkdir -p ../../../vendor/$MANUFACTURER/$DEVICE/proprietary'

  echo "$FILES" |
    while read FULLPATH
    do
      if test $FILESTYLE = extract
      then
        echo adb pull $FULLPATH ../../../vendor/\$MANUFACTURER/\$DEVICE/proprietary/$(basename $FULLPATH)
      else
        echo unzip -j -o ../../../\${DEVICE}_update.zip $(echo $FULLPATH | cut -b 2-) -d ../../../vendor/\$MANUFACTURER/\$DEVICE/proprietary
      fi
    done
  echo

  echo -n '(cat << EOF) | sed s/__DEVICE__/$DEVICE/g | sed s/__MANUFACTURER__/$MANUFACTURER/g > ../../../vendor/$MANUFACTURER/$DEVICE/'
  echo '$DEVICE-vendor-blobs.mk'

  echo '# Copyright (C) 2010 The Android Open Source Project'
  echo '#'
  echo '# Licensed under the Apache License, Version 2.0 (the "License");'
  echo '# you may not use this file except in compliance with the License.'
  echo '# You may obtain a copy of the License at'
  echo '#'
  echo '#      http://www.apache.org/licenses/LICENSE-2.0'
  echo '#'
  echo '# Unless required by applicable law or agreed to in writing, software'
  echo '# distributed under the License is distributed on an "AS IS" BASIS,'
  echo '# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.'
  echo '# See the License for the specific language governing permissions and'
  echo '# limitations under the License.'
  echo
  echo -n '# This file is generated by device/__MANUFACTURER__/__DEVICE__/'
  echo -n $FILESTYLE
  echo '-files.sh - DO NOT EDIT'

  FOUND=false
  echo "$FILES" |
    while read FULLPATH
    do
      if test $(basename $FULLPATH) = libgps.so -o $(basename $FULLPATH) = libcamera.so -o $(basename $FULLPATH) = libsecril-client.so
      then
        if test $FOUND = false
        then
          echo
          echo '# Prebuilt libraries that are needed to build open-source libraries'
          echo 'PRODUCT_COPY_FILES := \\'
        else
          echo \ \\\\
        fi
        FOUND=true
        echo -n \ \ \ \ vendor/__MANUFACTURER__/__DEVICE__/proprietary/$(basename $FULLPATH):obj/lib/$(basename $FULLPATH)
      fi
    done
  echo

  FOUND=false
  echo "$FILES" |
    while read FULLPATH
    do
      if test $FOUND = false
      then
        echo
        echo -n '# All the blobs necessary for '
        echo $DEVICENAME
        echo 'PRODUCT_COPY_FILES += \\'
      else
        echo \ \\\\
      fi
      FOUND=true
      echo -n \ \ \ \ vendor/__MANUFACTURER__/__DEVICE__/proprietary/$(basename $FULLPATH):$(echo $FULLPATH | cut -b 2-)
    done
  echo
  echo 'EOF'
  echo
  echo './setup-makefiles.sh'

  ) > $FILESTYLE-files.sh
done
