#include "ViewModel/MainViewModel.hpp"

MainViewModel::MainViewModel():
    appStateWrapper(new HsAppStateWrapper()) {}

MainViewModel::~MainViewModel() {
    delete appStateWrapper;
}


