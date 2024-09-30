{-# OPTIONS_GHC -fno-warn-orphans #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE ViewPatterns #-}

module SubApp
  ( module SubData
  , Route (..)
  ) where

import ClassyPrelude.Yesod
import SubData

instance YesodSubApp m => YesodSubDispatch SubApp m where
  yesodSubDispatch = $(mkYesodSubDispatch resourcesSubApp)

getHelloR :: YesodSubApp m => SubHandlerFor SubApp m Html
getHelloR = liftHandler $ defaultLayout [whamlet|<p>Hello, world!|]
