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
    
    var progressValue: Float = 0.0
    private var progressNumber: Float = 0.0
    
    //Установка в лейбл количества выпитой воды
    var valueWaterLabelChange: String {
        
        get {
            return valueWaterLabel.text!
        }
        
        set {
            valueWaterLabel.text = String(newValue)
        }
    }
    
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
        
        //Загрузка из CoreData
        loadCoreData()
        
        //Заполнение Лейбла и прогрессВью
        progressUpdateStartApp()
        
        //Настройка Вью
        setupView()
        
        //Наблюдатель для обновления CollectionView
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "delete"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "save"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(centerLabel(notification:)), name: NSNotification.Name(rawValue: "centerLabel"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressUpdate(notification:)), name: NSNotification.Name(rawValue: "waterValue"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(progressUpdateDelete(notification:)), name: NSNotification.Name(rawValue: "waterValueDelete"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //При загрузке проверка массива если пустой скрытие collectionView b  и отображение centerLabel
        if water == nil || water == [] {
            nilCoreDataArray()
            print("water == nil")
        } else if water != nil  {
            fillCoreDataArray()
            print("water != nil")
        }
    }
    
    //Для пустой CoreData
    func nilCoreDataArray() {
        centerViewLabel.isHidden = false
        collectionView.isHidden = true
        valueProgressView.setProgress(0, animated: false)
    }
    
    //Для заполненной CoreData
    func fillCoreDataArray() {
        collectionView.isHidden = false
        centerViewLabel.isHidden = true
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
    
    //Отслеживние массива waterSummary для обновления progressView(добавление)
    @objc func progressUpdate(notification: NSNotification) {
        
        guard let values = water else { return }
        progressValue = 0
        progressNumber = 0
        for i in values {
            progressValue += i.waterValue
        }
        
        //Установка значения в лейбл
        valueWaterLabelChange = String(Int(progressValue)) + " /2500 мл."
        
        //Для прогрессВью
        progressNumber = progressValue / 2500
        
        //Установка в прогрессВью
        valueProgressView.setProgress(progressNumber, animated: true)
    }
    
    //Отслеживние массива waterSummary для обновления progressView(удаление)
    @objc func progressUpdateDelete(notification: NSNotification) {
        
        guard let values = water else { return }
        
        //Обнуление если массив пустой
        if values.first?.waterValue == nil && values.last?.waterValue == nil {
            progressValue = 0
            print("This is refresh: " + "\(0)")
            valueWaterLabelChange = String(Int(progressValue)) + " /2500 мл."
            progressNumber = 0
            valueProgressView.setProgress(progressNumber, animated: true)
            
            //Логика подсчета значения прогрес из массива если он не пустой
        } else {
            progressValue = 0
            for i in values {
                progressValue += i.waterValue
            }
            valueWaterLabelChange = String(Int(progressValue)) + " /2500 мл."
            
            //Для прогрессВью
            progressNumber = progressValue / 2500
            
            //Установка в прогрессВью
            valueProgressView.setProgress(progressNumber, animated: true)
        }
    }
    
    private func progressUpdateStartApp() {
        if water == nil {
            valueWaterLabelChange = "0/2500 мл."
            valueProgressView.setProgress(0, animated: false)
        } else {
            progressValue = 0
            progressNumber = 0
            
            guard let values = water else { return }
            for i in values {
                progressValue += i.waterValue
            }
            
            //Установка значения в лейбл
            valueWaterLabelChange = String(Int(progressValue)) + " /2500 мл."
            
            //Для прогрессВью
            progressNumber = progressValue / 2500
            
            //Установка в прогрессВью
            valueProgressView.setProgress(progressNumber, animated: false)
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
        cell.waterValueLabel.text = String(Int(indexValueWater)) + " мл."
        cell.timeAddLabel.text = indexTime
        
        cell.layer.cornerRadius = 15
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 231 / 255, green: 231 / 255, blue: 231 / 255, alpha: 1).cgColor
        
    }
    
    //Загрузка из CoreData Water
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


