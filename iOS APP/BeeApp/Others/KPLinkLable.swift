import Foundation
import UIKit

enum ActiveType {
    case Mention
    case Hashtag
    case URL
    case Custom(pattern: String)
    var pattern: String {
        switch self {
        case .Mention: return RegexParser.mentionPattern
        case .Hashtag: return RegexParser.hashtagPattern
        case .URL: return RegexParser.urlPattern
        case .Custom(let regex): return regex
        }
    }
}

extension String {
    
    func getTagString(defaultFont: UIFont, defaultColor: UIColor, hasFont: UIFont, hasColor: UIColor, userNameFont: UIFont, userNameColor: UIColor, alignment: NSTextAlignment = .left) -> NSAttributedString {
        let attbStr = NSMutableAttributedString(string: self)
        let str = NSString(string: self)
        let range = str.range(of: str as String)
        
        
        attbStr.addAttribute(.font, value: defaultFont, range: range)
        attbStr.addAttribute(.foregroundColor, value: defaultColor, range: range)
        
        if let arrOfHasTags = RegexParser.getElements(from: self, with: RegexParser.hashtagPattern, range: range) {
            for has in arrOfHasTags {
                attbStr.addAttribute(.font, value: hasFont, range: has.range)
                attbStr.addAttribute(.foregroundColor, value: hasColor, range: has.range)
            }
        }
        
        if let arrOfUserNames = RegexParser.getElements(from: self, with: RegexParser.mentionPattern, range: range) {
            for userName in arrOfUserNames {
                attbStr.addAttribute(.font, value: userNameFont, range: userName.range)
                attbStr.addAttribute(.foregroundColor, value: userNameColor, range: userName.range)
            }
        }
        
        if let arrOfUrls = RegexParser.getElements(from: self, with: RegexParser.urlPattern, range: range) {
            for url in arrOfUrls {
                attbStr.addAttribute(.font, value: defaultFont, range: url.range)
                attbStr.addAttribute(.foregroundColor, value: UIColor.blue, range: url.range)
            }
        }

        let para = NSMutableParagraphStyle()
        para.alignment = alignment
        attbStr.addAttributes([NSAttributedString.Key.paragraphStyle: para], range: range)
        return attbStr
    }
}

struct RegexParser {
    static let hashtagPattern = "(?:^|\\s|$)#[\\p{L}0-9_]*"
    static let mentionPattern = "(?:^|\\s)@[\\p{L}0-9._-]*" //"(?:^|\\s|$|[.])@[\\p{L}0-9\\_-]*"
    static let urlPattern = "(^|[\\s.:;?\\-\\]<\\(])" +
        "((https?://|www\\.|pic\\.)[-\\w;/?:@&=+$\\|\\_.!~*\\|'()\\[\\]%#,☺]+[\\w/#](\\(\\))?)" +
    "(?=$|[\\s',\\|\\(\\).:;?\\-\\[\\]>\\)])"
    static let custom = "\\sit\\b"
    
    static func getElements(from text: String, with pattern: String, range: NSRange) -> [NSTextCheckingResult]? {
        if text.isEmpty {return nil}
        do {
            let elementRegex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
            return elementRegex.matches(in: text, options: [], range: NSRange(text.startIndex..., in: text))
        } catch let error {
            return []
        }
        //guard let elementRegex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]) else { return [] }
        //return elementRegex.matches(in: text, options: [], range: range)
    }
}

protocol KPLinkLabelDelagete: NSObjectProtocol {
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: KPLinkLabel)
    func tapOnEmpty(index: IndexPath?)
}

class SelectAttribute: NSObject {
    var range: NSRange!
    var type: ActiveType = ActiveType.Hashtag
}

class KPLinkLabel: UILabel, UITextViewDelegate {
    
    var hasSet: [NSTextCheckingResult] = []
    var mentionSet: [NSTextCheckingResult] = []
    var urlSet: [NSTextCheckingResult] = []
    var userName: [NSRange] = []
    var indexPath : IndexPath?
    
    private var heightCorrection: CGFloat = 0
    private lazy var textStorage = NSTextStorage()
    private lazy var layoutManager = NSLayoutManager()
    private lazy var textContainer = NSTextContainer()
    private var hasColor: UIColor!
    private var menColor: UIColor!
    private var urlColor: UIColor!
    private var selectedAttri:[SelectAttribute] = []
    weak var delegate: KPLinkLabelDelagete?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupLabel()
    }
    
    
    private func setupLabel() {
        textStorage.setAttributedString(self.attributedText!)
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = .byTruncatingTail
        textContainer.maximumNumberOfLines = 0
        isUserInteractionEnabled = true
    }
    
    override var intrinsicContentSize: CGSize {
        let superSize = super.intrinsicContentSize
        textContainer.size = CGSize(width: superSize.width, height: CGFloat.greatestFiniteMagnitude)
        let size = layoutManager.usedRect(for: textContainer)
        return CGSize(width: ceil(size.width), height: ceil(size.height))
    }
    
    // MARK: - Auto layout
    override func drawText(in rect: CGRect) {
        let range = NSRange(location: 0, length: textStorage.length)
        textContainer.size = rect.size
        let newOrigin = textOrigin(inRect: rect)
        layoutManager.drawBackground(forGlyphRange: range, at: newOrigin)
        layoutManager.drawGlyphs(forGlyphRange: range, at: newOrigin)
        setNeedsDisplay()
    }
    
    func setTagText(attriText: NSAttributedString, linebreak : NSLineBreakMode){
        attributedText = attriText
        textContainer.lineBreakMode = linebreak
        textStorage.setAttributedString(attriText)
        setNeedsDisplay()
        
        let str = NSString(string: attriText.string)
        let range = str.range(of: str as String)
        
        if let arrOfHashTag = RegexParser.getElements(from: self.attributedText!.string, with: RegexParser.hashtagPattern, range: range) {
            hasSet = arrOfHashTag
        }
        if let arrOfMentions = RegexParser.getElements(from: self.attributedText!.string, with: RegexParser.mentionPattern, range:range) {
            mentionSet = arrOfMentions 
        }
        if let arrOfUrls = RegexParser.getElements(from: self.attributedText!.string, with: RegexParser.urlPattern, range: range) {
            urlSet = arrOfUrls
        }
        
        userName = []
        attriText.enumerateAttribute(NSAttributedString.Key.attachment, in: range, options: []) { (attribute, rangeOfAtt, data) in
            if let _ = attribute {
                userName.append(rangeOfAtt)
            }
        }
    }
    
    // MARK: - touch event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch: touch) { return }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch: touch) { return }
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if onTouch(touch: touch) { return }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        _ = onTouch(touch: touch)
        super.touchesCancelled(touches, with: event)
    }
    
    
    private func textOrigin(inRect rect: CGRect) -> CGPoint {
        let usedRect = layoutManager.usedRect(for: textContainer)
        heightCorrection = (rect.height - usedRect.height)/2
        let glyphOriginY = heightCorrection > 0 ? rect.origin.y + heightCorrection : rect.origin.y
        return CGPoint(x: rect.origin.x, y: glyphOriginY)
    }
    
    private func onTouch(touch: UITouch) -> Bool {
        var avoidSuperCall = false
        var touchPoint:CGPoint = touch.location(in: self)
        touchPoint.y -= heightCorrection
        let glyphRect = layoutManager.boundingRect(forGlyphRange: NSMakeRange(0, self.attributedText!.string.utf16.count), in: textContainer)
        switch touch.phase {
        case .began, .moved:
            
            for tag in hasSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= tag.range.location && idx <= (tag.range.length + tag.range.location){
                        //setSelectedAttribute(range: tag.range, actType: ActiveType.Hashtag)
                        break
                    }
                }
            }
            
            for tag in mentionSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= tag.range.location && idx <= (tag.range.length + tag.range.location){
                        //setSelectedAttribute(range: tag.range, actType: ActiveType.Mention)
                        break
                    }
                }
            }
            
            for tag in urlSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= tag.range.location && idx <= (tag.range.length + tag.range.location){
                        //setSelectedAttribute(range: tag.range, actType: ActiveType.URL)
                        break
                    }
                }
            }
            
            for name in userName {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= name.location && idx <= (name.length + name.location){
                        //setSelectedAttribute(range: name, actType: ActiveType.URL)
                        break
                    }
                }
            }
            
            avoidSuperCall = true
            break
        case .ended:
            var tapFound = false
            for mention in mentionSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= mention.range.location && idx <= (mention.range.length + mention.range.location){
                        let strAtt = textStorage.attributedSubstring(from: mention.range)
                        delegate?.tapOnTag(tagName: strAtt.string,type: ActiveType.Mention, tappableLabel: self)
                        tapFound = true
                        break
                    }
                }
            }
            
            for tag in hasSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= tag.range.location && idx <= (tag.range.length + tag.range.location){
                        let strAtt = textStorage.attributedSubstring(from: tag.range)
                        delegate?.tapOnTag(tagName: String(strAtt.string),type: ActiveType.Hashtag, tappableLabel: self)
                        tapFound = true
                        break
                    }
                }
            }
            
            for url in urlSet {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= url.range.location && idx <= (url.range.length + url.range.location){
                        let strAtt = textStorage.attributedSubstring(from: url.range)
                        delegate?.tapOnTag(tagName: strAtt.string,type: ActiveType.URL, tappableLabel: self)
                        tapFound = true
                        break
                    }
                }
            }
            
            for name in userName {
                if glyphRect.contains(touchPoint) {
                    let idx = layoutManager.glyphIndex(for: touchPoint, in: textContainer)
                    if idx >= name.location && idx <= (name.length + name.location){
                        self.attributedText!.enumerateAttribute(NSAttributedString.Key.attachment, in: name, options: []) { (attribute, rangeOfAtt, data) in
                            if let attr = attribute {
                                delegate?.tapOnTag(tagName: attr as! String,type: .Mention, tappableLabel: self)
                            }
                        }
                        tapFound = true
                        break
                    }
                }
            }
            
            if !tapFound{
                delegate?.tapOnEmpty(index: indexPath)
            }
            
            //removeSelectedAttributed()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
                self.removeSelectedAttributed()
            })
            avoidSuperCall = true
            break
        case .cancelled:
            removeSelectedAttributed()
            break
        case .stationary:
            removeSelectedAttributed()
            break
        case .regionEntered:
            removeSelectedAttributed()
            break
        case .regionMoved:
            removeSelectedAttributed()
            break
        case .regionExited:
            removeSelectedAttributed()
            break
        @unknown default:
            removeSelectedAttributed()
            break
        }
        return avoidSuperCall
    }
    
    private func setSelectedAttribute(range: NSRange, actType: ActiveType){
        removeSelectedAttributed()
        
        let sel = SelectAttribute()
        sel.range = range
        sel.type = actType
        selectedAttri.append(sel)
        
        let attri: [NSAttributedString.Key: AnyObject]!
        switch actType {
        case .Hashtag:
            attri = [NSAttributedString.Key.foregroundColor: UIColor.gray]
            break
        case .Mention:
            attri = [NSAttributedString.Key.foregroundColor: UIColor.red]
            break
        default:
            attri = [NSAttributedString.Key.foregroundColor: UIColor.gray]
            break
        }
        textStorage.addAttributes(attri, range: range)
        setNeedsDisplay()
    }
    
    private func removeSelectedAttributed(){
        for item in selectedAttri {
            let attri: [NSAttributedString.Key: AnyObject]!
            switch item.type {
            case .Hashtag:
                attri = [NSAttributedString.Key.foregroundColor: UIColor.gray]
                break
            case .Mention:
                attri = [NSAttributedString.Key.foregroundColor: UIColor.red]
                break
            default:
                attri = [NSAttributedString.Key.foregroundColor: UIColor.red]
                break
            }
            textStorage.addAttributes(attri, range: item.range)
        }
        selectedAttri = []
        setNeedsDisplay()
    }
}

extension KPLinkLabel: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
