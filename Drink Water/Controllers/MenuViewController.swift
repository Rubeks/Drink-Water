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
    var weight: [Weight]?
    
    var progressValue: Float = 0.0
    private var progressNumber: Float = 0.0
    private var totalWater: Int = 0
    
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
    @IBOutlet weak var totalSummaryWaterLabel: UILabel!
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
        
        //Загрузка веса и количества воды необходимого выпить в сутки
        totalSummaryWaterUpdateStartApp()
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(updateTotalSummaryWater), name: NSNotification.Name(rawValue: "WeightChangeAndSave"), object: nil)
        
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
        valueWaterLabelChange = String(Int(progressValue))
        
        //Для прогрессВью
        progressNumber = progressValue / Float(totalWater)
        
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
            valueWaterLabelChange = String(Int(progressValue))
            progressNumber = 0
            valueProgressView.setProgress(progressNumber, animated: true)
            
            //Логика подсчета значения прогрес из массива если он не пустой
        } else {
            progressValue = 0
            for i in values {
                progressValue += i.waterValue
            }
            valueWaterLabelChange = String(Int(progressValue))
            
            //Для прогрессВью
            progressNumber = progressValue / 2500
            
            //Установка в прогрессВью
            valueProgressView.setProgress(progressNumber, animated: true)
        }
    }
    
    //Обновления общего количества воды которое нужно выпить.
    @objc func updateTotalSummaryWater() {
        self.navigationController?.navigationBar.alpha = 1
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Weight> = Weight.fetchRequest()
        
        do {
            weight = try context.fetch(fetchRequest)
            
            let genderLoad = weight?.first?.gender
            let weightLoad = weight?.first?.weight
            let physicalActivityLoad = weight?.first?.physicalActivity
            let sunLoad = weight?.first?.sunClimat
            let sickLoad = weight?.first?.sick
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-без солнца; 5-без болезни;
            if genderLoad == false && sunLoad == false && sickLoad == false {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
               
            //1-Мужик; 2-С весом; 3-с активностью; 4-с солнцем; 5-без болезни;
            if genderLoad == false && sunLoad == true && sickLoad == false {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.35) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-без солнцем; 5-с болезнью;
            if genderLoad == false && sunLoad == false && sickLoad == true {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.95) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
                
            //1-Мужик; 2-С весом; 3-с активностью; 4-с солнцем; 5-с болезнью;
            if genderLoad == false && sunLoad == true && sickLoad == true {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.35 + 0.95) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
                //-----------------------------------------
            
            //1-Женщина; 2-С весом; 3-с активностью; 4-без солнца; 5-без болезни;
            else if genderLoad == true && sunLoad == false && sickLoad == false {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            //1-Женщина; 2-С весом; 3-с активностью; 4-с солнцем; 5-без болезни;
            else if genderLoad == true && sunLoad == true && sickLoad == false {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.15) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
            //1-Женщина; 2-С весом; 3-с активностью; 4-без солнца; 5-с болезнью;
            else if genderLoad == true && sunLoad == false && sickLoad == true {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.85) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            //1-Женщина; 2-С весом; 3-с активностью; 4-с солнцем; 5- c болезью;
            else if genderLoad == true && sunLoad == true && sickLoad == true {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.15 + 0.85) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
        } catch {
            print(error)
        }
    }
    
    //Установка значения progressView при запуске приложения
    private func progressUpdateStartApp() {
        if water == nil || water == [] {
            valueWaterLabelChange = "0"
            valueProgressView.setProgress(0, animated: false)
            
        } else {
            
            progressValue = 0
            progressNumber = 0

            guard let values = water else { return }
            for i in values {
                progressValue += i.waterValue
            }

            //Установка значения в лейбл
            valueWaterLabelChange = String(Int(progressValue))

            //Для прогрессВью
            progressNumber = progressValue / Float(totalWater)

            //Установка в прогрессВью
            valueProgressView.setProgress(progressNumber, animated: false)
        }
    }
    
    ////Установка значения обшего количества воды при запуске приложения
    private func totalSummaryWaterUpdateStartApp() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<Weight> = Weight.fetchRequest()
        
        do {
            weight = try context.fetch(fetchRequest)
            
            let genderLoad = weight?.first?.gender
            let weightLoad = weight?.first?.weight
            let physicalActivityLoad = weight?.first?.physicalActivity
            let sunLoad = weight?.first?.sunClimat
            let sickLoad = weight?.first?.sick
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-без солнца; 5-без болезни;
            if genderLoad == false && sunLoad == false && sickLoad == false {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-с солнцем; 5-без болезни;
            if genderLoad == false && sunLoad == true && sickLoad == false {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.35) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-без солнцем; 5-с болезнью;
            if genderLoad == false && sunLoad == false && sickLoad == true {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.95) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            
            
            //1-Мужик; 2-С весом; 3-с активностью; 4-с солнцем; 5-с болезнью;
            if genderLoad == false && sunLoad == true && sickLoad == true {
                let value = Int((weightLoad! * 0.04 + physicalActivityLoad! * 0.6 + 0.35 + 0.95) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
                //-----------------------------------------
                
                //1-Женщина; 2-С весом; 3-с активностью; 4-без солнца; 5-без болезни;
            else if genderLoad == true && sunLoad == false && sickLoad == false {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
                //1-Женщина; 2-С весом; 3-с активностью; 4-с солнцем; 5-без болезни;
            else if genderLoad == true && sunLoad == true && sickLoad == false {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.15) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
                //1-Женщина; 2-С весом; 3-с активностью; 4-без солнца; 5-с болезнью;
            else if genderLoad == true && sunLoad == false && sickLoad == true {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.85) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
                
                //1-Женщина; 2-С весом; 3-с активностью; 4-с солнцем; 5- c болезью;
            else if genderLoad == true && sunLoad == true && sickLoad == true {
                let value = Int((weightLoad! * 0.03 + physicalActivityLoad! * 0.4 + 0.15 + 0.85) * 1000)
                totalWater = value
                totalSummaryWaterLabel.text = "/" + String(value) + "мл."
            }
            print("totalSummaryWaterUpdateStartApp " + "\(totalWater)")
        } catch {
            print(error)
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
    
    
    //Изменить бокал
    @IBAction func changeCupButton(_ sender: UIButton) {
        
        //Переход модальный
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ModalCupChange") as! ModalCollectionViewController
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
    }
    
    //Изменить вес
    @IBAction func changeWeightButton(_ sender: UIBarButtonItem) {
        
        self.navigationController?.navigationBar.alpha = 0.2
        
        let popUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WeightVC") as! WeightViewController
        self.addChild(popUpVC)
        popUpVC.view.frame = self.view.frame
        self.view.addSubview(popUpVC.view)
        popUpVC.didMove(toParent: self)
        
        NotificationCenter.default.post(name: NSNotification.Name("WeightButton"), object: nil)
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


