//
//  BlockMessageTests.swift
//
//  Copyright © 2018 BitcoinKit developers
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
@testable import BitcoinKit

class BlockMessageTests: XCTestCase {
    func testComputeMerkleRoot() throws {
        let block1 = loadRawBlock(named: "block1", in: .module)!
        XCTAssertEqual(block1.computeMerkleRoot(), block1.merkleRoot)

        let block413567 = loadRawBlock(named: "block413567", in: .module)!
        XCTAssertEqual(block413567.computeMerkleRoot(), block413567.merkleRoot)
    }

    private func loadRawBlock(named filename: String, in bundle: Bundle) -> BlockMessage? {
        guard let file = bundle.url(forResource: filename, withExtension: "raw") else {
            return nil
        }
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        return BlockMessage.deserialize(data)
    }
}
