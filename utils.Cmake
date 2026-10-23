set(THIRD_PARTY_INCLUDES ${CMAKE_BINARY_DIR}/third_party_includes)
file(MAKE_DIRECTORY ${THIRD_PARTY_INCLUDES})

function(ghdownloadversion gh_url gh_version)

    # https://github.com/user/repo/file.h
    #             v
    # /user/repo/file.h
    string(REGEX REPLACE "^https://github\\.com" "" path "${gh_url}")

    # detect /blob/master type links
    # user/repo/blob/master/somefolder/file.h
    #          v
    # CMAKE_MATCH_1 = user/repo
    # CMAKE_MATCH_2 = somefolder/file.h
    string(REGEX MATCH "^/([^/]+/[^/]+)/blob/[^/]+/(.+)$" is_blob "${path}")

    if(NOT is_blob)
    	# process regular gh links
    	# user/repo/somefolder/file.h
    	#          v
    	# CMAKE_MATCH_1 = user/repo
    	# CMAKE_MATCH_2 = somefolder/file.h
        string(REGEX MATCH "^/([^/]+/[^/]+)/(.+)$" MATCH "${path}")

        if(NOT MATCH)
            message(FATAL_ERROR "Invalid GitHub URL: ${gh_url}")
        endif()
    endif()

	# build versioned path
	# CMAKE_MATCH_1 = user/repo
	# CMAKE_MATCH_2 = somefolder/file.h
	# gh_version = v1.2.3
	#               v
	# user/repo/v1.2.3/somefolder/file.h
    set(versioned_path "/${CMAKE_MATCH_1}/${gh_version}/${CMAKE_MATCH_2}")
    set(localpath "${CMAKE_MATCH_2}")

    # Optional path to strip from final local storage path
    # somefolder/file.h
    #   v
    # file.h
    if(ARGC GREATER 2)
        string(REGEX REPLACE "^(.*/)?${ARGV2}/" "" localpath "${localpath}")
    endif()

    set(localpath "${THIRD_PARTY_INCLUDES}/${localpath}")

    file(DOWNLOAD
        "https://raw.githubusercontent.com${versioned_path}"
        "${localpath}"
    )

    message(STATUS "${gh_url} -> ${localpath}")
endfunction()
