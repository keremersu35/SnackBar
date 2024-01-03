import UIKit

public enum SnackbarPosition {
    case top
    case bottom
}

public enum SnackbarAnimation {
    case fade
    case scale
}

public final class SnackBar {
    public static let shared = SnackBar()

    private init() {}

    private let snackbarSpacing: CGFloat = 16
    private let animationDuration: TimeInterval = 0.3

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
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
        let view = UIStackView()
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var snackbarView: UIStackView = {
        let view = UIStackView()
        view.backgroundColor = .black
        view.axis = .horizontal
        view.alignment = .center
        view.layer.cornerRadius = snackbarSpacing
        view.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        view.isLayoutMarginsRelativeArrangement = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    public func showSnackbar(
        title: String? = nil,
        description: String,
        logo: UIImage? = nil,
        backgroundColor: UIColor = .black,
        textColor: UIColor = .white,
        position: SnackbarPosition = .bottom,
        animation: SnackbarAnimation = .fade,
        duration: TimeInterval = 2
    ) {

        if let title = title {
            titleLabel.text = title
            titleLabel.textColor = textColor
            innerStackView.addArrangedSubview(titleLabel)
            innerStackView.spacing = 4
        }

        descriptionLabel.textColor = textColor
        descriptionLabel.text = description
        innerStackView.addArrangedSubview(descriptionLabel)

        snackbarView.backgroundColor = backgroundColor
        if let logo = logo {
            logoView.image = logo
            logoView.tintColor = textColor
            logoView.heightAnchor.constraint(equalToConstant: 24).isActive = true
            logoView.widthAnchor.constraint(equalToConstant: 24).isActive = true
            snackbarView.spacing = 8
            snackbarView.addArrangedSubview(logoView)
        }
        snackbarView.addArrangedSubview(innerStackView)

        setConstraints(position: position)
        setEntranceAnimation(animation: animation)
        setExitAnimation(animation: animation, duration: duration)
    }

    private func setConstraints(position: SnackbarPosition) {
        guard let firstScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let firstWindow = firstScene.windows.first else { return }
        guard let viewController = firstWindow.rootViewController else { return }

        viewController.view.addSubview(snackbarView)

        let snackbarBottomConstraint: NSLayoutConstraint
        if position == .top {
            snackbarBottomConstraint = snackbarView.topAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor, constant: snackbarSpacing)
        } else {
            snackbarBottomConstraint = snackbarView.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.bottomAnchor, constant: -snackbarSpacing)
        }

        NSLayoutConstraint.activate([
            snackbarView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: snackbarSpacing),
            snackbarView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -snackbarSpacing),
            snackbarView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -snackbarSpacing),
            snackbarBottomConstraint,
        ])
    }

    private func setEntranceAnimation(animation: SnackbarAnimation) {
        var initialTransform: CGAffineTransform

        switch animation {
        case .fade:
            snackbarView.alpha = 0
            initialTransform = .identity
        case .scale:
            snackbarView.alpha = 1
            snackbarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            initialTransform = .identity
        }

        UIView.animate(withDuration: animationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: .curveEaseOut, animations: { [weak self] in
            guard let self = self else { return }
            self.snackbarView.alpha = 1
            self.snackbarView.transform = initialTransform
        }, completion: nil)
    }

    private func setExitAnimation(animation: SnackbarAnimation, duration: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: self.animationDuration, animations: {
                self.snackbarView.alpha = 0
                switch animation {
                case .fade:
                    self.snackbarView.transform = .identity
                case .scale:
                    self.snackbarView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }) { _ in
                self.snackbarView.removeFromSuperview()
            }
        }
    }
}
