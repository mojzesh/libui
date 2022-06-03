JOBS=$(shell sysctl -n hw.logicalcpu)
build-lib:
	@echo $(JOBS) \
	&& rm -rf ./build ./dist \
	&& mkdir -p ./build ./dist \
	&& cd ./build \
	&& cmake .. -DBUILD_SHARED_LIBS=OFF -DARCH:STRING=amd64 \
	&& make -j$(JOBS) \
	&& mv -f ./out/libui_darwin_amd64.a ./../dist/ \
	&& cmake .. -DBUILD_SHARED_LIBS=OFF -DARCH:STRING=arm64 \
	&& make -j$(JOBS) \
	&& mv -f ./out/libui_darwin_arm64.a ./../dist/
