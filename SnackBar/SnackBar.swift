import UIKit

public enum SnackbarPosition {
    case top
    case bottom
}

public enum SnackbarAnimation {
    case fade
    case slide
    case scale
}

public final class SnackBar {
    public static let shared = SnackBar()

    public init() {}
    
    let snackbarSpacing: CGFloat = 16
    let animationDuration: TimeInterval = 0.3
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = .zero
        label.textColor = .white
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logoView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var innerStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var snackbarView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [logoView, innerStackView])
        view.backgroundColor = .black
        view.axis = .horizontal
        view.alignment = .center
        view.layer.cornerRadius = snackbarSpacing
        view.layoutMargins = UIEdgeInsets(top: snackbarSpacing, left: snackbarSpacing, bottom: snackbarSpacing, right: snackbarSpacing)
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public func showSnackbar(
        title: String? = nil,
        description: String? = nil,
        logo: UIImage? = nil,
        backgroundColor: UIColor = .black,
        textColor: UIColor = .white,
        position: SnackbarPosition = .bottom,
        animation: SnackbarAnimation = .fade,
        duration: TimeInterval = 2
    ) {
    
        titleLabel.text = title
        titleLabel.textColor = textColor
        descriptionLabel.textColor = textColor
        descriptionLabel.text = description
        snackbarView.backgroundColor = backgroundColor
        if let logo {
            logoView.image = logo
            logoView.tintColor = textColor
            logoView.heightAnchor.constraint(equalToConstant: 16).isActive = true
            logoView.widthAnchor.constraint(equalToConstant: 16).isActive = true
            innerStackView.spacing = 8
        }

        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = firstScene.windows.first else { return }
        let viewController = firstWindow.rootViewController
        viewController?.view.addSubview(snackbarView)

        let snackbarBottomConstraint: NSLayoutConstraint
        if position == .top {
            snackbarBottomConstraint = snackbarView.topAnchor.constraint(equalTo: viewController!.view.safeAreaLayoutGuide.topAnchor, constant: snackbarSpacing)
        } else {
            snackbarBottomConstraint = snackbarView.bottomAnchor.constraint(equalTo: viewController!.view.safeAreaLayoutGuide.bottomAnchor, constant: -snackbarSpacing)
        }

        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: viewController!.view.leadingAnchor, constant: snackbarSpacing),
            snackbarView.trailingAnchor.constraint(equalTo: viewController!.view.trailingAnchor, constant: -snackbarSpacing),
            snackbarView.trailingAnchor.constraint(equalTo: viewController!.view.trailingAnchor, constant: -snackbarSpacing),
            snackbarBottomConstraint,
        ])

        var initialTransform: CGAffineTransform

        switch animation {
        case .fade:
            snackbarView.alpha = 0
            initialTransform = .identity
        case .slide:
            snackbarView.alpha = 1
            initialTransform = CGAffineTransform(translationX: 0, y: 0)
        case .scale:
            snackbarView.alpha = 1
            snackbarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            initialTransform = .identity
        }

        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
            guard let self else { return }
            self.snackbarView.alpha = 1
            self.snackbarView.transform = initialTransform
        }, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            UIView.animate(withDuration: self.animationDuration, animations: { [weak self] in
                guard let self else { return }
                self.snackbarView.alpha = 0
                switch animation {
                case .fade:
                    self.snackbarView.transform = .identity
                case .slide:
                    self.snackbarView.transform = CGAffineTransform(translationX: 0, y: 0)
                case .scale:
                    self.snackbarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }) { [weak self] _ in
                guard let self else { return }
                self.snackbarView.removeFromSuperview()
            }
        }
    }
}
