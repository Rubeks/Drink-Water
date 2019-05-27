//
//  ViewController.swift
//  Drink Water
//
//  Created by Раис Аглиуллов on 25/05/2019.
//  Copyright © 2019 Раис Аглиуллов. All rights reserved.
//

import UIKit
import CoreData

class MenuViewController: UIViewController {
    
    var water: [Water]?
    
    @IBOutlet weak var topCustomView: UIView!
    @IBOutlet weak var valueWaterLabel: UILabel!
    @IBOutlet weak var valueProgressView: UIProgressView!
    @IBOutlet weak var centerViewLabel: UILabel!
    @IBOutlet weak var addWaterButton: UIButton!
    @IBOutlet weak var changeCupButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
   
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCoreData()
        setupView()
        
        //Наблюдатель для обновления CollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "delete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "save"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(centerLabel(notification:)), name: NSNotification.Name(rawValue: "centerLabel"), object: nil)
    }
    
    //Перезагрузка CollectionView
    @objc func loadList(notification: NSNotification) {
       
        loadCoreData()
        self.collectionView.reloadData()
    }
    
    //Отслеживние массива water если чтобы скрывать centerLabel
    @objc func centerLabel(notification: NSNotification) {
        if water == nil || water == [] {
            centerViewLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            centerViewLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //При загрузке проверка массива если пустой скрытие collectionView b  и отображение centerLabel
        if water == nil || water == [] {
            centerViewLabel.isHidden = false
            collectionView.isHidden = true
            print("water == nil")
        } else if water != nil  {
            collectionView.isHidden = false
            centerViewLabel.isHidden = true
            print("water != nil")
        }
    }
    
    //Настройка Вью
    func setupView() {
        topCustomView.layer.cornerRadius = 15
        topCustomView.clipsToBounds = true
        topCustomView.layer.borderWidth = 2
        topCustomView.backgroundColor = .white
        topCustomView.layer.borderColor = UIColor(red: 231 / 255, green: 231 / 255, blue: 231 / 255, alpha: 1).cgColor
    }
    
    //Настройка ячейки
    func configureCell(cell: MenuCollectionViewCell, indexPath: IndexPath) {
        
        //Доступ к свойствам модели
        guard
            let indexImage = water?[indexPath.row].imageName,
            let indexValueWater = water?[indexPath.row].waterValue,
            let indexTime = water?[indexPath.row].time else { return }
        
        //Настройка вью ячейки
        cell.customImageView.image = UIImage(named: indexImage)
        cell.waterValueLabel.text = String(indexValueWater) + " мл."
        cell.timeAddLabel.text = indexTime
        
        cell.layer.cornerRadius = 15
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 231 / 255, green: 231 / 255, blue: 231 / 255, alpha: 1).cgColor
        
    }
    
    //Загрузка из CoreData
    func loadCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Water> = Water.fetchRequest()
        
        do {
            water = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    //Добавить воду
    @IBAction func addWaterButton(_ sender: UIButton) {
    }
    
    //Изменить бокал
    @IBAction func changeCupButton(_ sender: UIButton) {
        
        //Переход модальный
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModalCupChange") as! ModalCollectionViewController
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
    }
    
    //Тест
    @IBAction func loadButton(_ sender: UIBarButtonItem) {
        loadCoreData()
        self.collectionView.reloadData()
    }
    
}

extension MenuViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if water != nil {
            return water!.count
        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? MenuCollectionViewCell {
            
            configureCell(cell: cell, indexPath: indexPath)
            
            return cell
        }
        return UICollectionViewCell()
        
        
    }
}

extension MenuViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //Выбранная ячейка
        let selectedItemArray = water?[indexPath.row]
        
        //Номер ячейки
        let index = indexPath.row
        
        //Переход модальный
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SelectedCup") as! CupDetailViewController
        
        //Передача данных в модальный контроллер
        popUpVC.selectedItem = selectedItemArray
        popUpVC.index = index
        
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
        
    }
}


