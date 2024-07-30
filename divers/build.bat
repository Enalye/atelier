cd ..
dub build --config=atelier_dll_debug
dub build :app --config=atelier_dev_debug
dub build :app --config=atelier_redist_debug
mkdir bin\media\
copy media\* bin\media\
