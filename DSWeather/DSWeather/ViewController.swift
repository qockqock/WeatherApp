//
//  ViewController.swift
//  DSWeather
//
//  Created by 머성이 on 7/11/24.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    private var dataSource = [ForecastWeather]()
    
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
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .black
        // delegate: "대리자, 대신 수행을 해주는 사람."
        tableView.delegate = self
        // dataSource: 테이블 뷰 안에 집어넣을 데이터들.
        tableView.dataSource = self
        // 테이블 뷰 에다가 테이블 뷰 셀 등록
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.id)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        configureUI()
        fechForecastData()
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
                guard let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
                    print("JSON 디코딩 실패")
                    completion(nil)
                    return
                }
                completion(decodedData)
            } else {
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
                self.tempMaxLabel.text = "최소: \(Int(result.main.temp_min))"
                self.tempMinLabel.text = "최고: \(Int(result.main.temp_max))"
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
    
    // 서버에서 5일 간 날씨 예보 데이터를 불러오는 메서드
    private func fechForecastData() {
        var urlComponents = URLComponents(string: "https://api.openweathermap.org/data/2.5/forecast")
        urlComponents?.queryItems = self.urlQueryItems
        
        guard let url = urlComponents?.url else {
            print("잘못 된 URL")
            return
        }
        
        fetchData(url: url) { [weak self] (result: ForecastWeatherResult?) in
            guard let self, let result else { return }
            
            // 콘솔에다가 데이터를 잘 불러왔는지 찍어보기
            for forcastWeather in result.list {
                print("\(forcastWeather.main)\n\(forcastWeather.dtTxt)\n\n")
            }
            
            DispatchQueue.main.async {
                self.dataSource = result.list
                self.tableView.reloadData()
            }
        }
    }
    
    
    
    private func configureUI() {
        view.backgroundColor = .black
        [titleLabel, tempLabel, tempStackView, imgView, tableView].forEach{
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
        
        tableView.snp.makeConstraints{
            $0.top.equalTo(imgView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(50)
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    //테이블 뷰 셀 높이 지정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        40
    }
}

extension ViewController: UITableViewDataSource {
    // 테이블뷰의 indexPath 마다 테이블 뷰 셀을 지정.
    // indexPath = 테이블 뷰의 행과 섹션을 의미
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.id) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(forecastWeather: dataSource[indexPath.row])
        return cell
    }
    
    // 테이블 뷰 섹션에 행이 몇 개 들어가는가. 여기서 섹션은 없으니 그냥 총 행 개수를 입력
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    
}
