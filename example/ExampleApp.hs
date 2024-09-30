{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE UndecidableInstances #-}

module ExampleApp where

import ClassyPrelude.Yesod
import Control.Monad.Logger (runNoLoggingT)
import Database.Persist.Sql qualified as P
import Database.Persist.Sqlite qualified as P
import SubApp

data App = App
  { appHttpManager :: Manager
  , appConnPool :: P.ConnectionPool
  , appSubApp :: SubApp
  }

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
LossRunEvent sql=loss_run_events
  name Text
  deriving Show
|]

mkYesod "App" [parseRoutes|
/ HomeR GET
/sub SubR SubApp appSubApp
|]

getHomeR :: Handler Html
getHomeR = do
  events <- runDB $ selectList [] [ Asc LossRunEventId ]
  defaultLayout [whamlet|
    $newline never
    <h1>Loss Run Events
    $if not (null events)
      <ul>
      $forall event <- events
        <li>#{tshow event}
  |]

instance Yesod App where
  defaultLayout w = do
    p <- widgetToPageContent w
    withUrlRenderer [hamlet|
      $newline never
      $doctype 5
      <html lang="en">
        <head>
          <title>#{pageTitle p}
          ^{pageHead p}
        <body>
          ^{pageBody p}
    |]

instance YesodPersist App where
  type YesodPersistBackend App = P.SqlBackend
  runDB action = getYesod >>= P.runSqlPool action . appConnPool

instance YesodSubApp App

instance RenderMessage App FormMessage where
  renderMessage _ _ = defaultFormMessage

instance HasHttpManager App where
  getHttpManager = appHttpManager

makeFoundation :: Text -> IO App
makeFoundation dbname = do
  pool <- runNoLoggingT $ P.createSqlitePool dbname 10
  _ <- runNoLoggingT (P.runSqlPool (P.runMigrationQuiet migrateAll) pool)
  App <$> newManager <*> pure pool <*> liftIO newSubApp

makeApplication :: App -> IO Application
makeApplication foundation = do
  appPlain <- toWaiAppPlain foundation
  pure $ defaultMiddlewaresNoLogging appPlain

getApplicationRepl :: IO (Int, App, Application)
getApplicationRepl = do
  foundation <- makeFoundation "db.sqlite3"
  app1       <- makeApplication foundation
  pure (3000, foundation, app1)

shutdownApp :: App -> IO ()
shutdownApp _foundation = pure ()
