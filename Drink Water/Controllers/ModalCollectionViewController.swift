//
//  ModalCollectionViewController.swift
//  Drink Water
//
//  Created by Раис Аглиуллов on 27/05/2019.
//  Copyright © 2019 Раис Аглиуллов. All rights reserved.
//

import UIKit
import CoreData

class ModalCollectionViewController: UIViewController {
    
    let imageNames = ["150ml", "200ml", "250ml", "300ml", "500ml"]
    let valueWater = [150, 200, 250, 300 , 500]
    
    var water: [Water]?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var customView: UIView!
    
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //При загрузке окна запуск анимации
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        moveIn()
        
    }
    
    //Настройка ячейки
    func configureCell(cell: ModalCollectionViewCell, indexPath: IndexPath) {
        
        let indexImage = imageNames[indexPath.row]
        let indexValueWater = valueWater[indexPath.row]
        
        cell.myImageView.image = UIImage(named: indexImage)
        cell.waterValueLabel.text = String(indexValueWater) + "мл."
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(red: 231 / 255, green: 231 / 255, blue: 231 / 255, alpha: 1).cgColor
        
    }
    
    //Анимация входа
    func moveIn() {
        self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
        self.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.24) {
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.view.alpha = 1.0
        }
    }
    
    //Анимация выхода
    func moveOut() {
        UIView.animate(withDuration: 0.24, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.35, y: 1.35)
            self.view.alpha = 0.0
        }) { _ in
            self.view.removeFromSuperview()
        }
    }
    
    //Сохранение в БД выбранный стакан чтобы отобразить в CollectionView MenuVC
    func saveItemInsideCoreData(imageName: String, waterValue: Int, time: String) {
        
        // Добираюсь до АпДелегат. Нужно будет для свойства СейвКонтекст
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        // Получаю сам контекст
        let context = appDelegate.persistentContainer.viewContext
        
        // Создаю сущность (в корДата все работает через сущности - своего рода класс)
        
        let entity = NSEntityDescription.entity(forEntityName: "Water", in: context)
        
        // Создаю сам объект( из сущности и контекста) который хочу сохранить
        let item = NSManagedObject(entity: entity!, insertInto: context) as! Water
        
        // Устанавливаю значение для carObject (из принимаемого значения функцией)
        item.imageName = imageName
        item.waterValue = Int32(waterValue)
        item.time = time
        
        // Сохраняю контекст, для того чтобы сохранился сам объект
        do {
            try context.save()
            water?.append(item)
            print("Saved!")
        } catch {
            print(error)
        }
    }
}

extension ModalCollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as? ModalCollectionViewCell {
            
            configureCell(cell: cell, indexPath: indexPath)
            
            return cell
        }
        
        return UICollectionViewCell()
        
    }
    
    
}

extension ModalCollectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        //Индекс картинки из массива
        let imageIndex = imageNames[indexPath.row]
        //Значение мл. для бокала
        let valueWaterIndex = valueWater[indexPath.row]
        
        //Время добавления
        let thisTime = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        let resultDate = formatter.string(from: thisTime)
        
        //Сохранение в CoreData
        saveItemInsideCoreData(imageName: imageIndex, waterValue: valueWaterIndex, time: resultDate)
        
        //Отправка уведомления об изменении значения
        NotificationCenter.default.post(name: NSNotification.Name("save"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("centerLabel"), object: nil)
        
        //Анимация выхода
        moveOut()
    }
}

