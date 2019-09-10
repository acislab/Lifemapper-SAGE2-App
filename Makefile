ELMFLAGS = --yes --warn

all: boom.tar.gz mcpa.tar.gz
	cp -r mcpa/elm webapp/
	cp mcpa/treeView.html.template webapp/treeView.html
	cp mcpa/index.html.template webapp/index.html
	#cp mcpa/packageView.html.template webapp/packageView.html # TODO: a template probably isn't necessary

debug: ELMFLAGS += --debug
debug: all

boom.tar.gz: boom/elm/boomMain.js boom/elm/subsetpam.js boom/*
	#git describe --tags > boom/VERSION
	echo "BOOM-TEST" > boom/Version
	tar -zcvf boom.tar.gz --exclude=boomFlagsOverride.js boom

mcpa.tar.gz: mcpa/elm/StatsHeatMap.js mcpa/elm/TreeView.js mcpa/elm/Package.js mcpa/*
	#git describe --tags > mcpa/VERSION
	echo "MCPA-TEST" > mcpa/VERSION
	tar -zcvf mcpa.tar.gz mcpa

boom/elm/boomMain.js: source/Decoder.elm source/*
	elm-make source/Main.elm $(ELMFLAGS) --output=boom/elm/boomMain.js

boom/elm/subsetpam.js:  source/Decoder.elm source/*
	elm-make source/SubsetPam.elm $(ELMFLAGS) --output=boom/elm/subsetpam.js

mcpa/elm/Package.js: source/Package.elm source/*
	elm-make source/Package.elm $(ELMFLAGS) --output=mcpa/elm/Package.js

mcpa/elm/StatsHeatMap.js: source/Decoder.elm source/*
	elm-make source/StatsHeatMap.elm $(ELMFLAGS) --output=mcpa/elm/StatsHeatMap.js

mcpa/elm/TreeView.js: source/Decoder.elm source/*
	elm-make source/TreeView.elm $(ELMFLAGS) --output=mcpa/elm/TreeView.js

source/Decoder.elm: swagger.json source/Decoder.elm.patch
	cat swagger.json | swagger-to-elm | elm-format --stdin > source/Decoder.elm.generated
	patch -o source/Decoder.elm -i source/Decoder.elm.patch source/Decoder.elm.generated
	rm -f source/Decoder.elm.generated

clean:
	rm -f source/Decoder.elm
	rm -f boom.tar.gz boom/elm.js
	rm -f mcpa.tar.gz mcpa/elm/*.js

test: source/Decoder.elm source/* tests/*.elm
	elm test

.PHONY: all debug clean test
