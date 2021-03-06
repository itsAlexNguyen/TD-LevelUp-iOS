import IGListKit

import Foundation

public protocol DashboardWidgetModel {
    /// The Title of the Widget
    var title: String { get }
    
    /// The content view for the widget
    var contentView: DashboardWidgetView { get }
    
    /// The icon for the widget
    var icon: UIImage? { get }
    
    /// Preferred Height
    var preferredHeight: CGFloat { get }
    
    /// Indicates the user wants to open this widget
    func openWidget(with viewcontroller: UIViewController)

}

extension DashboardWidgetModel {
    public var preferredHeight: CGFloat {
        return 300.0
    }
}

public class DashboardWidgetController: ListSectionController {
    var model: DashboardWidgetModel?
    
    public override func didUpdate(to object: Any) {
        model = object as? DashboardWidgetModel
    }
    
    public override func sizeForItem(at index: Int) -> CGSize {
        guard let collectionContext = collectionContext, let model = model else { return CGSize.zero}
        return CGSize(width: collectionContext.containerSize.width, height: model.preferredHeight)
    }
    
    public override func cellForItem(at index: Int) -> UICollectionViewCell {
        guard let cell = collectionContext?.dequeueReusableCell(of: DashboardWidgetCell.self, for: self, at: index) as? DashboardWidgetCell else {
            fatalError("Could not dequeue DashboardWidgetCell")
        }
        cell.widgetIconImageView.image = model?.icon
        model?.contentView.viewcontroller = viewController
        cell.widgetContent = model?.contentView
        cell.titleLabel.text = model?.title
        return cell
    }
    
    public override func didSelectItem(at index: Int) {
        guard let viewController = viewController else { return }
        model?.openWidget(with: viewController)
    }
}
