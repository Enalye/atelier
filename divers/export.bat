cd ..
del /q export\*
dub build --config=atelier_dll --build=release-nobounds
dub build :studio --config=export --build=release-nobounds
dub build :app --config=atelier_dev --build=release-nobounds
dub build :app --config=atelier_redist --build=release-nobounds
del export\*.lib
del export\*.exp
del export\*.pdb
copy License.txt export\license.txt
copy README.md export\lisez-moi.md
mkdir export\media\
copy media\* export\media\
echo export terminé
