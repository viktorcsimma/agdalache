target_sources(
    ${PROJECT_NAME}
    PRIVATE HsAppStateWrapper.cpp Future.cpp
)
target_sources(
    ${PROJECT_NAME}Test
    PRIVATE HsAppStateWrapper.cpp
)
