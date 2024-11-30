#ifndef MAIN_VIEW_MODEL_HPP_
#define MAIN_VIEW_MODEL_HPP_

#include "Backend/HsAppStateWrapper.hpp"

// A view model containing different elements
// which the main window will need.
class MainViewModel {
    private:
        // This will be a containment;
        // it only has the size of a pointer
        // and no swapping is needed
        // in the lifetime of the view model.
        HsAppStateWrapper appStateWrapper;

    public:
        MainViewModel() {} // this also initialises the appStateWrapper

        // We delete the copy constructor and the assignment operator.
        MainViewModel(const MainViewModel& temp_obj) = delete;
        MainViewModel& operator=(const MainViewModel& temp_obj) = delete;
};

#endif
