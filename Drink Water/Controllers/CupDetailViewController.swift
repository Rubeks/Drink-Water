//
//  CupDetailViewController.swift
//  Drink Water
//
//  Created by Раис Аглиуллов on 27/05/2019.
//  Copyright © 2019 Раис Аглиуллов. All rights reserved.
//

import UIKit
import CoreData

class CupDetailViewController: UIViewController {
    
    var water: [Water]?
    var selectedItem: Water?
    var index: Int?
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var waterValueCup: UILabel!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var customView: UIView!
    
    
    //MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Загрузка
        loadCoreData()
        
        //Настройка
        setupView()
        setupInsadeViews()
        
        //При загрузке окна запуск анимации
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        moveIn()
        
    }
    
    //Настройка внутренних компонентов Вью
    func setupInsadeViews() {
        
        guard let item = selectedItem else { return }
        
        timeLabel.text = item.time
        waterValueCup.text = String(item.waterValue)
        customImageView.image = UIImage(named: item.imageName!)
    }
    
    //Настройка Вью
    func setupView() {
        customView.layer.cornerRadius = 10
        customView.clipsToBounds = true
        customView.layer.borderWidth = 4
        customView.layer.borderColor = UIColor(red: 66 / 255, green: 186 / 255, blue: 69 / 255, alpha: 1).cgColor
        
    }
    
    //Загрузка кор дата
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
    
    //Кнопка ОК
    @IBAction func okButton(_ sender: UIButton) {
        moveOut()
    }
    
    //Кнопка удаления
    @IBAction func deleteButton(_ sender: UIButton) {
        
        // Добираюсь до АпДелегат. Нужно будет для свойства СейвКонтекст
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        // Получаю сам контекст
        let context = appDelegate.persistentContainer.viewContext
        
        //Удаление из БД
        //Удаление из массива
        water?.remove(at: index!)
        //Удаление из контекста
        context.delete(selectedItem!)
        
        //Сохранение
        do {
            try context.save()
        } catch {
            print(error)
        }
        
        print("delete item success")
        
        //Отправка уведомления об изменении значения
        NotificationCenter.default.post(name: NSNotification.Name("delete"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("centerLabel"), object: nil)
        
        moveOut()
    }
}
