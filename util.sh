# Copyright 2016 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

################################################################################
# Build font instances from Glyphs source.
# Arguments:
#     Path to Glyphs source.
#     Output formats, as separate strings.
################################################################################
function build_glyphs() {
    fontmake -g "$1" -o "${@:2}" -i
}

################################################################################
# Build font instances from plist source, which designates separate MTI feature
# files to use with a corresponding Glyphs source.
# Arguments:
#     Path to plist source.
#     Output formats, as separate strings.
################################################################################
function build_plist() {
    pathops="$(pathops_arg "$1")"
    glyphs="$(glyphs_from_plist "$1")"
    family="$(family_from_plist "$1")"
    if [[ -n "$family" ]]; then
        fontmake -g "$glyphs" -o "${@:2}" --mti-source "$1"\
            --no-production-names --family-name "$family" ${pathops} 
        fontmake -g "$glyphs" -o "${@:2}" -i --interpolate-binary-layout\
            --no-production-names --family-name "$family" ${pathops}
    else
        fontmake -g "$glyphs" -o "${@:2}" --mti-source "$1"\
            --no-production-names ${pathops}
        if should_interpolate "$1"; then
            fontmake -g "$glyphs" -o "${@:2}" -i --interpolate-binary-layout\
                --no-production-names ${pathops}
        fi
    fi
}

################################################################################
# Build font instances from designspace and UFOs.
# Arguments:
#     Path to designspace source.
#     Output formats, as separate strings.
################################################################################
function build_designspace() {
    fontmake -m "$1" -i -o "${@:2}" --expand-features-to-instances
}


################################################################################
# Build variable font from designspace and UFOs.
# Arguments:
#     Path to designspace source.
################################################################################
function build_designspace_variable() {
    fontmake -m "$1" -o variable
}

################################################################################
# Build variable font from Glyphs source.
# Arguments:
#     Path to Glyphs source.
################################################################################
function build_glyphs_variable() {
    fontmake -g "$1" -o variable
}

################################################################################
# Build variable font from plist source.
# Arguments:
#     Path to plist source.
################################################################################
function build_plist_variable() {
    pathops="$(pathops_arg "$1")"
    glyphs="$(glyphs_from_plist "$1")"
    family="$(family_from_plist "$1")"
    if [[ -n "${family}" ]]; then
        fontmake -g "${glyphs}" -o variable --mti-source "$1"\
            --family-name "${family}" ${pathops}
    else
        fontmake -g "${glyphs}" -o variable --mti-source "$1" ${pathops}
    fi
}

################################################################################
# Build from UFO source, assuming that the source contains quadratic curves (for
# which BooleanOperations is unable to remove overlaps, and only TTFs can be
# generated).
# Arguments:
#     Path to UFO source.
################################################################################
function build_ufo() {
    fontmake -u "$1" -o 'ttf' --keep-overlaps
}

function glyphs_from_plist() {
    glyphs="${1/%.plist/.glyphs}"
    case "$1" in
        */NotoSansDevanagariUI-MM.plist|\
        */NotoSansTamilUI-MM.plist|\
        */NotoSansBengaliUI-MM.plist|\
        */NotoSansMalayalamUI-MM.plist|\
        */NotoSansKannadaUI-MM.plist|\
        */NotoSansGurmukhiUI-MM.plist|\
	    */NotoSansSinhalaUI-MM.plist|\
	    */NotoSansTeluguUI-MM.plist)
            echo "${glyphs/UI/}"
            ;;
        *)
            echo "${glyphs}"
            ;;
    esac
}

function pathops_arg() {
    case "$1" in
        */Arimo-*|\
        */Cousine-*|\
        */Tinos-*)
            echo  '--overlaps-backend pathops'
            ;;
        *)
            echo ''
            ;;
    esac
}

function family_from_plist() {
    case "$1" in
        */NotoSansDevanagari-MM.plist)
            echo 'Noto Sans Devanagari'
            ;;
        */NotoSansDevanagariUI-MM.plist)
            echo 'Noto Sans Devanagari UI'
            ;;
        */NotoSansTamil-MM.plist)
            echo 'Noto Sans Tamil'
            ;;
        */NotoSansTamilUI-MM.plist)
            echo 'Noto Sans Tamil UI'
            ;;
        */NotoSansBengali-MM.plist)
            echo 'Noto Sans Bengali'
            ;;
        */NotoSansBengaliUI-MM.plist)
            echo 'Noto Sans Bengali UI'
            ;;
        */NotoSansKannada-MM.plist)
            echo 'Noto Sans Kannada'
            ;;
        */NotoSansKannadaUI-MM.plist)
            echo 'Noto Sans Kannada UI'
            ;;
        */NotoSansMalayalam-MM.plist)
            echo 'Noto Sans Malayalam'
            ;;
        */NotoSansMalayalamUI-MM.plist)
            echo 'Noto Sans Malayalam UI'
            ;;
        */NotoSansGurmukhi-MM.plist)
            echo 'Noto Sans Gurmukhi'
            ;;
        */NotoSansGurmukhiUI-MM.plist)
            echo 'Noto Sans Gurmukhi UI'
            ;;
        */NotoSansSinhala-MM.plist)
            echo 'Noto Sans Sinhala'
            ;;
        */NotoSansSinhalaUI-MM.plist)
            echo 'Noto Sans Sinhala UI'
            ;;
        */NotoSansTelugu-MM.plist)
            echo 'Noto Sans Telugu'
            ;;
        */NotoSansTeluguUI-MM.plist)
            echo 'Noto Sans Telugu UI'
            ;;
        *)
            echo ''
            ;;
    esac
}

function should_interpolate() {
    case "$1" in
        */NotoNastaliqUrdu.plist)
            false
            ;;
        */NotoSansJavanese-MM.plist)
            false
            ;;
        */Arimo-*|\
        */Cousine-*|\
        */Tinos-*)
            false
            ;;
        *)
            true
            ;;
    esac
}
