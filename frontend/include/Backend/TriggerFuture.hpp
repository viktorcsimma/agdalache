#ifndef TRIGGERFUTURE_HPP_
#define TRIGGERFUTURE_HPP_

#include <thread>
#include <functional>
#include <vector>

#include "Future.hpp"

/**
 * A variant of Future
 * which executes triggers attached
 * when the result is ready.
 */
template<typename T>
class TriggerFuture: private Future<T> {
  private:
    // The thread on which we will run
    // the get() calls and the triggers.
    std::thread triggerThread;

    // The triggers to be run.
    std::vector<std::function<void(T)>> triggers;

    // The code calling get() and the triggers.
    void triggerThreadCode() {
        try {
            int result = this->get();

            // we lock only here
            std::unique_lock lock(this->mutex);

            for (auto t: triggers) t(result);
        } catch (InterruptedFutureException()) {}
    }

  public:
    TriggerFuture(std::function<void(HsPtr)> callback,
                    const std::vector<std::function<void(T)>>& triggers = std::vector<std::function<void(T)>>(0)):
          Future<T>(callback), triggers(triggers),
        triggerThread([=]() {
            triggerThreadCode();
        })
    {}

    // A move constructor,
    // designed similarly to that of std::future.
    // It makes the source Future invalid.
    TriggerFuture( Future<T>&& other, const std::vector<std::function<void(T)>>& triggers = std::vector<std::function<void(T)>>(0) ) noexcept:
            Future<T>(other),
            triggerThread([=]() {
                triggerThreadCode();
            }),
            triggers(triggers)    {
        // as we call the move constructor of Future,
        // that will invalidate the previous one
        // without us having to do anything else
    };

    // The return value means
    // whether there has really been a calculation to interrupt.
    bool interrupt() {
        std::unique_lock lock(this->mutex);
        if (this->interrupted()) return false;
        else {
            static_cast<Future<T>*>(this)->interrupt();
            // wait until the thread stops gracefully
            if (triggerThread.joinable()) triggerThread.join();
            return true;
        }
    }
};

#endif
