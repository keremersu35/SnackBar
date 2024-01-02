import UIKit

final class ViewController: UIViewController {
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Click to show SnackBar", for: .normal)
        button.titleLabel?.textColor = .white
        button.layer.cornerRadius = 8
        button.backgroundColor = .blue
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(onTapButton), for: .touchUpInside)
        return button
    }()
    
    @objc private func onTapButton() {
        SnackBar.shared.showSnackbar(title: "This is a title", description: "It's a message for the SnackBar ! It's a message for the SnackBar ! It's a message for the SnackBar ! It's a message for the SnackBar !", animation: .slide)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        makeButton()
    }
    
    private func makeButton() {
        view.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}

