//
//  ViewController.swift
//  DSWeather
//
//  Created by 머성이 on 7/11/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    // URL 쿼리 아이템들
    private let urlQueryItems: [URLQueryItem] = [
        URLQueryItem(name: "lat", value: "37.5"),
        URLQueryItem(name: "lon", value: "126.9"),
        URLQueryItem(name: "appid", value: "a6390e5972416a3d05f9422154eafd0a"),
        URLQueryItem(name: "units", value: "metric"),
    ]
    
    // 메인 레이블 관련
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "인천광역시"
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 30)
        
        return label
    }()
    
    // 메인 온도 관련
    private let tempLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .boldSystemFont(ofSize: 50)
        //        label.text = "20도"
        return label
    }()
    
    // 최소온도관련
    private let tempMaxLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        //        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    // 최소온도 관련
    private let tempMinLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        //        label.text = "20도"
        label.font = .boldSystemFont(ofSize: 20)
        
        return label
    }()
    
    // 최소온도와 최고온도를 담을 스택뷰
    private let tempStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        
        return stackView
    }()
    
    private let imgView:UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .black
        
        return imgView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
        fetchCurrentWeatherData()
    }
    
    // 메서드의 책임을 생각 해 볼것
    // 서버 데이터를 불러오는 메서드
    private func fetchData<T: Decodable>(url: URL, completion: @escaping (T?) -> Void) {
        let session = URLSession(configuration: .default)
        session.dataTask(with: URLRequest(url: url)) { data, response, error in
            guard let data, error == nil else {
                print("데이터 로드 실패")
                completion(nil)
                return
            }
            // http status code 성공 범위는 200번대 (타입캐스팅 뭐였지?)
            let successRange = 200..<300
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else{
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else{
                print("응답 오류")
                completion(nil)
            }
        }.resume()
    }
    
    // 서버에서 현재 날씨 데이터를 불러오는 메서드
    private func fetchCurrentWeatherData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못된 URL")
            return
        }
        
        // 메인 쓰레드 관련
        fetchData(url: url) { [weak self] (result: CurrentWeatherResult?) in
            guard let self, let result else { return }
            
            // UI관련은 요 안에
            DispatchQueue.main.async {
                self.tempLabel.text = "\(Int(result.main.temp))°C"
                self.tempMaxLabel.text = "최소: \(Int(result.main.tempMin))"
                self.tempMinLabel.text = "최고: \(Int(result.main.tempMax))"
            }
            
            guard let imgUrl = URL(string: "https://openweathermap.org/img/wn/\(result.weather[0].icon)@2x.png") else {
                return
            }
            
            if let data = try? Data(contentsOf: imgUrl) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imgView.image = image
                    }
                }
            }
            
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        [titleLabel, tempLabel, tempStackView, imgView].forEach{
            view.addSubview($0)
        }
        
        // 와 이건 머임? (addArrangedSubview) 메모
        [tempMinLabel, tempMaxLabel].forEach{
            tempStackView.addArrangedSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(120)
        }
        
        tempLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        tempStackView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(tempLabel.snp.bottom).offset(10)
        }
        
        imgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(160)
            $0.top.equalTo(tempStackView.snp.bottom).offset(20)
        }
    }
    
}

