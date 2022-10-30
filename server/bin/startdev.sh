echo "Starting development server"
plackup --env development --server Plack::Handler::Standalone --app lacuna.psgi --reload -R /home/lacuna/server/lib,/home/lacuna/server/var
