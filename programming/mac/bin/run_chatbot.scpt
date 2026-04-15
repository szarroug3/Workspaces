-- Opens 3 tabs in iTerm2 using the CURRENT window:
--   Tab 1 = current tab (vets-website on 3001)
--   Tab 2 = vets-api on 3000
--   Tab 3 = directline-mock on 3002/3003

tell application "iTerm2"
  activate

  -- Use the current window if it exists, otherwise create one
  if (count of windows) = 0 then
    set theWindow to (create window with default profile)
  else
    set theWindow to current window
  end if

  -- TAB 1: use the CURRENT tab/session
  tell current session of theWindow to write text ¬
    "cd ~/git/work/VA/vets-website && " & ¬
    "(lsof -n -P -iTCP:3001 -sTCP:LISTEN -t | xargs kill -9 || true) && " & ¬
    "sleep 1 && nvm use && yarn watch --env entry=auth,claims-status,static-pages,login-page,terms-of-use,verify,virtual-agent"

  tell theWindow
    -- TAB 2: vets-api (kill only LISTENers on 3000)
    set tab2 to (create tab with default profile)
    tell current session of tab2 to write text ¬
      "cd ~/git/work/VA/vets-api && " & ¬
      "(lsof -n -P -iTCP:3000 -sTCP:LISTEN -t | xargs kill -9 || true) && " & ¬
      "sleep 1 && bundle exec rails s"

    -- TAB 3: directline-mock (kill only LISTENers on 3002 and 3003)
    set tab3 to (create tab with default profile)
    tell current session of tab3 to write text ¬
      "cd ~/git/work/VA/va-virtual-agent/skills/directline-mock && " & ¬
      "(lsof -n -P -iTCP:3002 -sTCP:LISTEN -t | xargs kill -9 || true) && " & ¬
      "(lsof -n -P -iTCP:3003 -sTCP:LISTEN -t | xargs kill -9 || true) && " & ¬
      "sleep 1 && npm run watch"
  end tell
end tell

