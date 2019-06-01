//
//  WeightViewController.swift
//  Drink Water
//
//  Created by Раис Аглиуллов on 01/06/2019.
//  Copyright © 2019 Раис Аглиуллов. All rights reserved.
//

import UIKit
import CoreData

class WeightViewController: UIViewController {
    
    var weight: [Weight]?
    
    var genderClassValue: Bool?
    var weightClassValue: Float?
    var physicalActivityClassValue: Float?
    var sunClimatClassValue: Bool?
    var sickClassValue: Bool?
    
    
    @IBOutlet weak var genderSegmentControl: UISegmentedControl!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var weightSlider: UISlider! {
        didSet {
            weightSlider.value = 50
            weightSlider.minimumValue = 30
            weightSlider.maximumValue = 140
        }
    }
    @IBOutlet weak var physicalActivityLabel: UILabel!
    @IBOutlet weak var physicalActivitySlider: UISlider!  {
        didSet {
            physicalActivitySlider.value = 0
            physicalActivitySlider.minimumValue = 0.5
            physicalActivitySlider.maximumValue = 6
        }
    }
    @IBOutlet weak var sunClimat: UISwitch!
    @IBOutlet weak var sickSwitch: UISwitch!
    @IBOutlet weak var customView: UIView!
    
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //При загрузке окна запуск анимации
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        moveIn()
        setupView()
        
        loadWeightFromCoreData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(load), name: NSNotification.Name(rawValue: "WeightButton"), object: nil)
        
        //Заполнение полей при загрузке
        fillProperty()
        
        fillOutlets()
        
        //Наблюдатель за сегментедКонтрол
        genderSegmentControl.addTarget(self, action: #selector(segmentedControlChange), for: .valueChanged)
        
    }
    
    //Для изменения свойства класса genderClassValue
    @objc func segmentedControlChange() {
        if genderSegmentControl.selectedSegmentIndex == 0 {
            genderClassValue = false
        } else {
            genderClassValue = true
        }
        //print(genderClassValue)
    }
    
    @objc func load() {
        loadWeightFromCoreData()
    }
    
    //Анимация входа
    private func moveIn() {
        self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    //Анимация выхода
    private func moveOut() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
    
    //Настройка Вью
    private func setupView() {
        customView.layer.cornerRadius = 10
        customView.clipsToBounds = true
        customView.layer.borderWidth = 4
        customView.layer.borderColor = UIColor(red: 66 / 255, green: 186 / 255, blue: 69 / 255, alpha: 1).cgColor
        
    }
    
    //MARK: CoreData
    private func loadWeightFromCoreData() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Weight> = Weight.fetchRequest()
        
        do {
            weight = try context.fetch(fetchRequest)
        } catch {
            print(error)
        }
    }
    
    private func saveWeightToCoreData(gender: Bool, weightValue: Float, physicalActivity: Float, sunClimat: Bool, sick: Bool) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Weight", in: context)
        
        // Создаю сам объект( из сущности и контекста) который хочу сохранить
        let item = NSManagedObject(entity: entity!, insertInto: context) as! Weight
        
        // Устанавливаю значение (из принимаемого значения функцией)
        
        item.gender = gender
        item.weight = weightValue
        item.physicalActivity = physicalActivity
        item.sunClimat = sunClimat
        item.sick = sick
        
        // Сохраняю контекст, для того чтобы сохранился сам объект
        do {
            try context.save()
            weight?.append(item)
            print("Saved!")
        } catch {
            print(error)
        }
    }
    
    //Заполнение полей при загрузке
    private func fillProperty() {
        
        if weight == nil || weight == [] {
            genderClassValue = false
            weightClassValue = 50
            physicalActivityClassValue = 0
            sunClimatClassValue = false
            sickClassValue = false
        } else {
            genderClassValue = weight?.first?.gender
            weightClassValue = weight?.first?.weight
            physicalActivityClassValue = weight?.first?.physicalActivity
            sunClimatClassValue = weight?.first?.sunClimat
            sickClassValue = weight?.first?.sick
        }
    }
    
    private func fillOutlets() {
        
        //segment
        if genderClassValue == true {
            genderSegmentControl.selectedSegmentIndex = 1
        } else {
            genderSegmentControl.selectedSegmentIndex = 0
        }
        
        //weight
        weightLabel.text = String(Int(weightClassValue!)) + " кг."
        weightSlider.value = weightClassValue!
        
        //physicalActivity
        physicalActivityLabel.text = String(physicalActivityClassValue!) + " ч."
        physicalActivitySlider.value = physicalActivityClassValue!
        
        //sun
        if sunClimatClassValue == true {
            sunClimat.setOn(true, animated: false)
        } else {
            sunClimat.setOn(false, animated: false)
        }
        
        //sick
        if sickClassValue == true {
            sickSwitch.setOn(true, animated: false)
        } else {
            sickSwitch.setOn(false, animated: false)
        }
    }
    
    
    //MARK: Actions Methods
    @IBAction func genderSegmentControl(_ sender: UISegmentedControl) {
    }
    
    //Изменение веса
    @IBAction func weightSlider(_ sender: UISlider) {
        
        //Шаг и округление
        let step: Float = 1
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        //Сохранение значения в переменную и лейбл
        weightClassValue = sender.value
        weightLabel.text = String(Int(weightClassValue!)) + " кг."
        //print(weightClassValue)
    }
    
    //Изменение времени тренировки
    @IBAction func physicalActivitySlider(_ sender: UISlider) {
        
        //Шаг и округление
        let step: Float = 0.5
        let roundedValue = round(sender.value / step) * step
        sender.value = roundedValue
        
        //Сохранение значения в переменную и лейбл
        physicalActivityClassValue = sender.value
        physicalActivityLabel.text = String(physicalActivityClassValue!) + " ч."
        //print(physicalActivityClassValue)
    }
    
    //Жарко ли на улице
    @IBAction func sunClimatSwitch(_ sender: UISwitch) {
        if sender.isOn {
            sunClimatClassValue = true
        } else {
            sunClimatClassValue = false
        }
        
        //print(sunClimatClassValue)
    }
    
    //Болеет ли человек
    @IBAction func sickSwitch(_ sender: UISwitch) {
        if sickSwitch.isOn {
            sickClassValue = true
        } else {
            sickClassValue = false
        }
        
        //print(sickClassValue)
    }
    
    @IBAction func saveButton(_ sender: UIButton) {
        
        if weight == nil || weight == [] {
            
            saveWeightToCoreData(gender: genderClassValue!, weightValue: weightClassValue!, physicalActivity: physicalActivityClassValue!, sunClimat: sunClimatClassValue!, sick: sickClassValue!)
            
            moveOut()
        }
        
        else {
            let firstItem = weight?.first
            // Добираюсь до АпДелегат. Нужно будет для свойства СейвКонтекст
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            // Получаю сам контекст
            let context = appDelegate.persistentContainer.viewContext
            
            //Удаление из массива
            weight?.removeAll()
            
            //Удаление из контекста
            context.delete(firstItem!)
            
            //Сохранение
            do {
                try context.save()
            } catch {
                print(error)
            }
            
            print("delete item success")
            
            saveWeightToCoreData(gender: genderClassValue!, weightValue: weightClassValue!, physicalActivity: physicalActivityClassValue!, sunClimat: sunClimatClassValue!, sick: sickClassValue!)
            
            moveOut()
        }
    }
}


