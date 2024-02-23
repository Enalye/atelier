cd ..
del /q export\*
dub build --config=atelier_dll --build=release-nobounds
cd atelier
dub build --config=atelier_dev --build=release-nobounds
dub build --config=atelier_redist --build=release-nobounds
cd ..
del export\*.lib
del export\*.exp
del export\*.pdb
copy License.txt export\license.txt
copy README.md export\lisez-moi.md
echo export terminé
