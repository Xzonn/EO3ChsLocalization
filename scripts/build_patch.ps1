$packer = "bin\NDS_Atlus_Packer\packer.exe"

# Clean output folder
if (Test-Path -Path "out\" -PathType "Container") {
  Remove-Item -Recurse -Force "out\"
}
if (Test-Path -Path "temp\" -PathType "Container") {
  Remove-Item -Recurse -Force "temp\"
}

# Unpack/extract original files
if (-Not (Test-Path -Path "original_files\data\Data\@Target\Data\Font\Font8x8.cmp" -PathType "Leaf")) {
  if (Test-Path -Path "original_files\data\Data\@Target\" -PathType "Container") {
    Remove-Item -Recurse -Force "original_files\data\Data\@Target\"
  }
  & $packer "original_files\data\Data\Target" | Out-Null
}
New-Item -ItemType "Directory" -Path "temp\pack\" | Out-Null
Copy-Item -Path "original_files\data\Data\*" -Destination "temp\pack\" -Recurse
& $packer "temp\pack\Target" | Out-Null

python scripts\decompress_arm9.py

python scripts\generate_char_table.py
python scripts\generate_char_list.py
python scripts\create_font.py

python scripts\convert_json_to_mbm.py
python scripts\convert_json_to_tbl.py
python scripts\convert_json_to_tbl_type_2.py
python scripts\convert_json_to_binary.py

python scripts\import_images.py

& $packer "temp\pack\Target" "temp\out\data\Data\Target" | Out-Null

python scripts\compile_arm9_patch.py
python scripts\recompress_arm9.py
python scripts\create_xdelta.py

python scripts\edit_banner.py

Copy-Item -Path "original_files\md5.txt" -Destination "out\md5.txt" -Force

Compress-Archive -Path "out/xdelta/", "out/banner.bin", "out/md5.txt" -Destination "patch-ds.zip" -Force
Move-Item -Path "patch-ds.zip" -Destination "out/patch-ds-original.xzp" -Force

# Additional images from HD Remastered version
python scripts\import_images_additional.py
& $packer "temp\pack\Target" "temp\out\data\Data\Target" | Out-Null
python scripts\create_xdelta.py
Compress-Archive -Path "out/xdelta/", "out/banner.bin", "out/md5.txt" -Destination "patch-ds.zip" -Force
Move-Item -Path "patch-ds.zip" -Destination "out/patch-ds-remastered.xzp" -Force
