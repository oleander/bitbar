import Quick
import Nimble
@testable import BitBar

class ImageTests: Helper {
  func verifyBase64(_ parser: P<Image>, _ name: String) {
    describe(name) {
      it("handles valid string") {
        self.match(parser, name + "=dGVzdGluZw==") {
          expect($0.getValue()).to(equal("dGVzdGluZw=="))
          expect($1).to(equal(""))
        }
      }

      context("whitespace") {
        let image = "dGVzdGluZw=="
        it("strips pre whitespace") {
          self.match(parser, name + "=    " + image) {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }

        it("strips post whitespace") {
          self.match(parser, name + "=" + image + "  ") {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }

        it("strips whitespace") {
          self.match(parser, name + "=  " + image + "  ") {
            expect($0.getValue()).to(equal(image))
            expect($1).to(equal(""))
          }
        }
      }

      context("fails") {
        it("fails on empty string") {
          self.failure(parser, name + "=")
        }
      }
    }
  }

  override func spec() {
    describe("parser") {
      describe("image") {
        verifyBase64(Pro.getImage(), "image")
      }

      describe("templateImage") {
        verifyBase64(Pro.getTemplateImage(), "templateImage")
      }
    }
  }
}
