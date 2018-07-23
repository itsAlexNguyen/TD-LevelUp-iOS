import Foundation
import UIKit
import IGListKit
import SnapKit

public class InvestingWidgetView: DashboardWidgetView, InvestingWidgetViewContract {
    /// The Adapter used for the IGListKit Collection View.
    public var adapter: ListAdapter?
    
    override public var viewcontroller: UIViewController! {
        didSet {
            adapter = ListAdapter(updater: ListAdapterUpdater(), viewController: viewcontroller)
            adapter?.dataSource = self
            adapter?.collectionView = collectionView
            adapter?.scrollViewDelegate = self
        }
    }
    
    lazy var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return layout
    }()
    
    lazy var pageControl: UIPageControl = {
        let view = UIPageControl()
        view.currentPage = 0
        view.pageIndicatorTintColor = .darkGray
        view.currentPageIndicatorTintColor = .white
        addSubview(view)
        return view
    }()
    
    /// Collection view that fills the controller.
    public lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: collectionViewFlowLayout)
        view.backgroundColor = .black
        view.alwaysBounceVertical = false
        view.alwaysBounceHorizontal = true
        view.showsHorizontalScrollIndicator = false
        view.isPagingEnabled = true
        addSubview(view)
        return view
    }()
    
    var intents: [InvestingIntent] = [] {
        didSet {
            pageControl.numberOfPages = intents.count
            pageControl.currentPage = 0
        }
    }
    
    public override func prepareView() {
        collectionView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalToSuperview()
            make.center.equalToSuperview()
        }
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }

    public func updatePromotionalIntents(_ items: [InvestingIntent]) {
        self.intents = items
        adapter?.performUpdates(animated: true, completion: nil)
    }
}

extension InvestingWidgetView: UIScrollViewDelegate {
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let w = scrollView.bounds.size.width
        let currentPage = Int(ceil(x/w))
        if currentPage >= 0 && currentPage < intents.count {
            pageControl.currentPage = currentPage
        }
    }
}

extension InvestingWidgetView: ListAdapterDataSource {
    public func objects(for listAdapter: ListAdapter) -> [ListDiffable] {
        var objects: [ListDiffable] = []
        for intent in intents {
            objects.append(InvestingPromotionItem(intent: intent,
                                                  image: UIImage(named: "investing_banner_\((intents.index{ $0 === intent} ?? 0) % 6)")))
        }
        return objects
    }
    
    public func listAdapter(_ listAdapter: ListAdapter, sectionControllerFor object: Any) -> ListSectionController {
        return PromotionSectionController()
    }
    
    public func emptyView(for listAdapter: ListAdapter) -> UIView? {
        return nil
    }
}
