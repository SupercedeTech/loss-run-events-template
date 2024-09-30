{-# LANGUAGE OverloadedStrings #-}

module SubAppSpec where

import TestImport

spec :: Spec
spec = withApp $ do

  it "Loads the master site's home page" $ do
    get HomeR
    statusIs 200
    htmlAllContain "h1" "Loss Run Events"

  it "Loads the subsite's home page" $ do
    get $ SubR HelloR
    statusIs 200
    htmlAllContain "p" "Hello, world!"
