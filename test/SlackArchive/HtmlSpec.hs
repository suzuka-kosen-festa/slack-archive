{-# LANGUAGE OverloadedStrings #-}

module SlackArchive.HtmlSpec
  ( spec
  ) where


import qualified Data.ByteString    as B
import qualified Data.Text          as T
import qualified Data.Text.Encoding as TE
import qualified Data.Yaml          as Yaml
import qualified System.Directory   as Dir
import           Test.Hspec

import           SlackArchive.Html


spec :: Spec
spec = do
  w <- runIO $ do
    config <- Yaml.decodeFileThrow "slack-archive.yaml"
    loadWorkspaceInfo config "test/assets"

  let idOfRandom = "C4M4TT8JJ"
  -- The random channel configured in slack-archive.yaml
      p = PageInfo
        { pageNumber       = 35
        , thisPagePath     = "/html/35.html"
        , previousPagePath = Just "/html/34.html"
        , nextPagePath     = Just "/html/36.html"
        , channelId        = idOfRandom
        }

  describe "renderSlackMessages" $
    it "converts messages in Slack into a byte string of HTML" $ do
      expected <- readAsExpectedHtml "test/assets/expected-messages.html"
      Dir.withCurrentDirectory "test/assets" $
        renderSlackMessages w p `shouldReturn` expected

  describe "renderThread" $
    it "converts replies in Slack into a byte string of HTML" $ do
      expected <- readAsExpectedHtml "test/assets/expected-replies.html"
      Dir.withCurrentDirectory "test/assets" $
        renderThread w p "1547694882.115200.json" `shouldReturn` expected

  describe "renderIndexOfPages" $
    it "build index HTML of HTML pages." $ do
      expected <- readAsExpectedHtml "test/assets/expected-index.html"
      let channelAndPaths = [(idOfRandom, ["test/assets/35.json"])]

      Dir.withCurrentDirectory "test/assets" $
        renderIndexOfPages w channelAndPaths `shouldReturn` expected


readAsExpectedHtml :: FilePath -> IO T.Text
readAsExpectedHtml = fmap (T.replace "\r\n" "\n" . TE.decodeUtf8) . B.readFile
