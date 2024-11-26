#ifndef MAIN_VIEW_MODEL_HPP_
#define MAIN_VIEW_MODEL_HPP_

#include <string>
#include <mutex>
#include <thread>

#include "Backend/Future.hpp"
#include "Backend/HsAppStateWrapper.hpp"

// A view model containing different elements
// which the main window will need.
class MainViewModel {
    private:
        // This will be a pointer;
        // it needs to be swappable
        // and that is easier to do this way.
        HsAppStateWrapper* appStateWrapper;

    public:
        // This also automatically constructs a HsAppStateWrapper
        // and stores its pointer.
        MainViewModel();

        // This also frees the HsAppStateWrapper.
        ~MainViewModel();

        // We delete the copy constructor and the assignment operator.
        MainViewModel(const MainViewModel& temp_obj) = delete;
        MainViewModel& operator=(const MainViewModel& temp_obj) = delete;
};

#endif
