#ifndef FUTURE_HPP_
#define FUTURE_HPP_

#include "TinyHsFFI.h"

#include <exception>
#include <functional>
#include <mutex>
#include <cstdio>

/**
 * The exception thrown if trying to manipulate an invalid Future.
 */
class InvalidFutureException: public std::exception {};
/**
 * The exception thrown by the get() call when the Future is interrupted.
 */
class InterruptedFutureException: public std::exception {};

/**
 * A class for handling Haskell futures.
 * Is thread-safe.
 */
template<typename T>
class Future {
    private:
        // Whether the Future is valid (i.e. really tied to an asynchronous calculation or its result).
        bool _valid;

        // Whether the result has been successfully queried
        // and therefore cached in the object itself.
        bool _queried;
        // Whether the calculation has been interrupted.
        bool _interrupted;
        // A place for the result if it has been calculated.
        T result;

        // The two StablePtrs:
        // the first for the interruption MVar
        // and the second for the result MVar.
        // The array structure guarantees that
        // the two pointers are going to be next to each other
        // (the backend expects such a structure).
        HsStablePtr stablePtrs[2];

        // A mutex embedded in the Future object.
        std::mutex mutex;

        // Gets the value from the Future,
        // without checking whether it is valid
        // or manipulating the flags.
        // It only calls the appropriate Haskell function;
        // do not use elsewhere than in get().
        // This needs different instantiations for different T types
        // to be able to call the appropriate getter from Future.h.
        T haskellGet() noexcept;

    public:
        // Initialises the Future
        // while also adding triggers
        // before starting the actual calculation.
        Future(std::function<void(HsPtr)> callback):
            _valid(true), _queried(false), _interrupted(false) {
            callback(stablePtrs);
        }

        // Whether the Future is valid (i.e. really tied to an asynchronous calculation or its result).
        bool valid() const {return _valid;}

        // Whether the result has been successfully queried
        // and therefore cached in the object itself.
        bool queried() const {return _queried;}

        // Whether the calculation has been interrupted manually.
        bool interrupted() const {return _interrupted;}

        // Getting the result (waiting for it if not ready)
        // while also freeing the StablePtrs inside.
        // Throws InterruptedFutureException if the calculation has been interrupted.
        // After this, queried() gets true.
        T get() {
            std::unique_lock lock(mutex);
            if (!valid()) throw InvalidFutureException();
            else if (queried()) return result;
            else {
                // unlocking so that interrupt() can run
                lock.unlock();
                result = haskellGet();
                lock.lock();
                if (interrupted()) throw InterruptedFutureException(); // the interruption has also freed the StablePtrs
                else {
                    hs_lock_stable_ptr_table();
                    hs_free_stable_ptr_unsafe(stablePtrs[0]);
                    hs_free_stable_ptr_unsafe(stablePtrs[1]);
                    hs_unlock_stable_ptr_table();
                    _queried = true;
                    return result;
                }
            }
        }

        // Interrupting the calculation while also freeing the StablePtrs inside.
        // After this, valid() gets false and interrupted() gets true.
        // If queried() is true, valid() is false or interrupted() is true,
        // then returns false and does nothing.
        bool interrupt() {
            std::unique_lock lock(mutex);
            if (queried() || !valid() || interrupted()) return false;
            else {
                _valid = false;
                _interrupted = true;
                hs_try_putmvar(-1, stablePtrs[0]); // this also frees the pointer
                hs_free_stable_ptr(stablePtrs[1]);
                return true;
            }
        };

        // The move constructor,
        // designed similarly to that of std::future.
        // It makes the previous Future invalid.
        Future( Future&& other ) noexcept: _valid(other._valid), _queried(other._queried), result(other.result) {
            stablePtrs[0] = other.stablePtrs[0];
            stablePtrs[1] = other.stablePtrs[1];
            other._valid = false; // they should not get freed twice
        };

        // The move assignment operator,
        // designed similarly to that of std::future.
        // It makes the previous Future invalid.
        Future& operator=( Future&& other ) noexcept {
            _valid = other._valid;
            _queried = other._queried;
            result = other.result;
            stablePtrs[0] = other.stablePtrs[0];
            stablePtrs[1] = other.stablePtrs[1];
            other._valid = false;
            return *this;
        }

        // Deleting the copy constructor.
        Future( const Future& other ) = delete;

        // Deleting the copy assignment operator.
        Future& operator=( const Future& other ) = delete;

        // Deleting the default constructor so that
        // only the Haskell runtime can create instances.
        Future() = delete;

        // The destructor.
        // If the calculation is in progress, it gets interrupted
        // (raising an exception in threads that might be waiting for the result).
        ~Future() {
            if (valid() && !queried()) {
                interrupt();
            }
        }
};

// Now the concrete instantiations.
// The definitions are in the cpp file;
// they correspond to the different calls for different primitive types
// in Future.h.
template<>
int Future<int>::haskellGet() noexcept;

#endif
