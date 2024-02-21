cd ..
dub build --config=atelier_dll
cd atelier
dub build --config=atelier_dev
dub build --config=atelier_redist
cd ..
echo export terminé
