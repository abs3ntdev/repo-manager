function clean_repo_path
    set stripped $argv[1]
    set stripped (string replace -r "^http://" "" $stripped)
    set stripped (string replace -r "^https://" "" $stripped)
    set stripped (string replace -r "^git@" "" $stripped)
    set stripped (string replace -r "^ssh://" "" $stripped)
    set stripped (string replace -r "^aur@" "" $stripped)
    set stripped (string replace -r ":" "/" $stripped)

    if not string match -q "*/*" $stripped
        set stripped "github.com/$stripped"
    end
    echo "$stripped"
end