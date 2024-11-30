target_sources(
    ${PROJECT_NAME}
    PRIVATE HsAppStateWrapper.hpp Future.hpp TriggerFuture.hpp
)
target_sources(
    ${PROJECT_NAME}Test
    PRIVATE HsAppStateWrapper.hpp
)
