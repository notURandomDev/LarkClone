//
//  LaunchViewController.swift
//  LaunchViewController
//
//  Created by Kyle Huang on 2025/5/11.
//

import Foundation
import UIKit

public class LaunchViewController: UIViewController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        // 背景，使用动态颜色适配暗黑模式
        view.backgroundColor = .systemBackground

        // Logo 和 "飞书" 文字的组合
        let logoStackView = UIStackView()
        logoStackView.axis = .horizontal
        logoStackView.alignment = .center
        logoStackView.spacing = 4
        logoStackView.translatesAutoresizingMaskIntoConstraints = false

        // Logo 图片
        let logoImageView = UIImageView(image: UIImage(named: "LaunchLogo", in: Bundle(for: LaunchViewController.self), compatibleWith: nil))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        logoImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true

        // "飞书" 文字
        let titleLabel = UILabel()
        titleLabel.text = "飞书"
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label // 动态文字颜色
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        // 将 Logo 和文字添加到 StackView
        logoStackView.addArrangedSubview(logoImageView)
        logoStackView.addArrangedSubview(titleLabel)
        view.addSubview(logoStackView)

        // 底部文字 "先造团队 先用飞书"
        let sloganLabel = UILabel()
        sloganLabel.text = "先进团队   先用飞书"
        sloganLabel.font = .systemFont(ofSize: 12)
        sloganLabel.textColor = .secondaryLabel // 动态次要文字颜色
        sloganLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sloganLabel)

        // Auto Layout 约束
        NSLayoutConstraint.activate([
            // 底部文字距离屏幕底部 50 点
            sloganLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            sloganLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            
            // Logo StackView
            logoStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoStackView.bottomAnchor.constraint(equalTo: sloganLabel.topAnchor, constant: -15),

        ])
    }
}
