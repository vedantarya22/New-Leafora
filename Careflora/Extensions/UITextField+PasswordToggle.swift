import UIKit

extension UITextField {
    func enablePasswordToggle() {
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        button.tintColor = .systemGray
        button.addTarget(self, action: #selector(self.togglePasswordView(_:)), for: .touchUpInside)
        
        let container = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 40)
        container.addSubview(button)
        
        self.rightView = container
        self.rightViewMode = .always
    }
    
    private func setPasswordToggleImage(_ button: UIButton) {
        if isSecureTextEntry {
            button.setImage(UIImage(systemName: "eye.slash"), for: .normal)
        } else {
            button.setImage(UIImage(systemName: "eye"), for: .normal)
        }
    }
    
    @objc private func togglePasswordView(_ sender: UIButton) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender)
        
        // This preserves the cursor position and fixes the font resetting issue when toggling secure text entry
        if let textRange = self.textRange(from: self.beginningOfDocument, to: self.endOfDocument) {
            self.replace(textRange, withText: self.text ?? "")
        }
    }
}
